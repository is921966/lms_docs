module Fastlane
  module Actions
    class FetchTestflightFeedbackV2Action < Action
      def self.run(params)
        require 'spaceship'
        require 'json'
        require 'fileutils'
        
        UI.message "🚀 Fetching TestFlight feedback using Spaceship..."
        
        begin
          # Authenticate with App Store Connect
          key_content = File.read(params[:key_filepath])
          
          Spaceship::ConnectAPI.auth(
            key_id: params[:key_id], 
            issuer_id: params[:issuer_id], 
            key: key_content
          )
          
          UI.success "✅ Successfully authenticated with App Store Connect"
          
          # Get app
          app = Spaceship::ConnectAPI::App.find(params[:app_identifier])
          
          if app.nil? && params[:app_id]
            UI.message "🔍 App not found by bundle ID, trying by app ID..."
            app = Spaceship::ConnectAPI::App.get(app_id: params[:app_id])
          end
          
          if app.nil?
            UI.error "❌ App not found: #{params[:app_identifier]}"
            
            # List available apps to help debug
            UI.message "📱 Available apps:"
            all_apps = Spaceship::ConnectAPI::App.all(limit: 10)
            all_apps.each do |a|
              UI.message "  - #{a.name} (#{a.bundle_id}) - ID: #{a.id}"
            end
            
            return 0
          end
          
          UI.success "📱 Found app: #{app.name} (#{app.bundle_id})"
          
          # Create output directory
          output_dir = params[:output_directory] || "testflight_feedback_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
          FileUtils.mkdir_p(output_dir)
          FileUtils.mkdir_p("#{output_dir}/screenshots")
          
          # Try to get beta testers and their feedback
          UI.message "🔍 Fetching beta testers..."
          
          # Get all beta testers
          testers = Spaceship::ConnectAPI.get_beta_testers(
            filter: { apps: app.id },
            limit: 200
          )
          
          UI.message "Found #{testers.count} beta testers"
          
          # Get beta builds
          builds = app.get_builds(
            includes: "buildBetaDetail",
            limit: 10
          )
          
          UI.message "Found #{builds.count} builds"
          
          # Create report
          report = {
            app_identifier: params[:app_identifier],
            app_name: app.name,
            generated_at: Time.now.iso8601,
            total_testers: testers.count,
            total_builds: builds.count,
            testers: [],
            builds: []
          }
          
          # Process testers
          testers.each do |tester|
            tester_data = {
              email: tester.email,
              first_name: tester.first_name,
              last_name: tester.last_name,
              invite_type: tester.invite_type,
              beta_groups: (tester.beta_groups.map(&:name).join(", ") rescue "")
            }
            report[:testers] << tester_data
          end
          
          # Process builds
          builds.each_with_index do |build, index|
            # Debug first build
            if index == 0
              UI.message "Build class: #{build.class.name}"
            end
            
            build_data = {
              version: build.version,
              build_id: build.id,
              uploaded_date: build.uploaded_date,
              processing_state: build.processing_state,
              expired: build.expired || false
            }
            report[:builds] << build_data
          end
          
          # Try alternative methods for feedback
          UI.message "🔍 Attempting to fetch feedback through alternative methods..."
          
          # Method 1: Try to get beta feedback 
          begin
            all_testers = Spaceship::ConnectAPI.get_beta_testers(
              filter: { apps: app.id },
              includes: "betaTesterApps,betaGroups",
              limit: 200
            )
            
            all_testers.each do |tester|
              # Check if tester has feedback
              if tester.beta_tester_apps && tester.beta_tester_apps.any?
                tester.beta_tester_apps.each do |tester_app|
                  UI.message "Tester app data: #{tester_app.inspect}" if index == 0
                end
              end
            end
          rescue => e
            UI.message "Could not fetch detailed tester data: #{e.message}"
          end
          
          # Method 2: Customer Reviews (might include TestFlight feedback)
          begin
            reviews = Spaceship::ConnectAPI.get_customer_reviews(
              filter: { 'app' => app.id },
              includes: "response",
              limit: 100
            )
            
            UI.message "Found #{reviews.count} customer reviews"
            
            report[:reviews] = reviews.map do |review|
              {
                rating: review.rating,
                title: review.title,
                body: review.body,
                reviewer_nickname: review.reviewer_nickname,
                created_date: review.created_date
              }
            end
          rescue => e
            UI.message "Could not fetch customer reviews: #{e.message}"
          end
          
          # Save report
          report_path = "#{output_dir}/feedback_report.json"
          File.write(report_path, JSON.pretty_generate(report))
          UI.success "📊 Report saved to: #{report_path}"
          
          # Create summary
          create_summary(report, output_dir)
          
          # Print summary
          UI.message ""
          UI.message "=== TestFlight Summary ==="
          UI.message "App: #{report[:app_name]}"
          UI.message "Total testers: #{report[:total_testers]}"
          UI.message "Total builds: #{report[:total_builds]}"
          
          if report[:reviews] && report[:reviews].any?
            UI.message "Customer reviews: #{report[:reviews].count}"
          end
          
          return report[:total_testers]
          
        rescue => e
          UI.error "❌ Error: #{e.message}"
          UI.error e.backtrace.join("\n") if params[:verbose]
          return 0
        end
      end
      
      def self.create_summary(report, output_dir)
        summary_path = "#{output_dir}/summary.txt"
        
        File.open(summary_path, 'w') do |f|
          f.puts "TestFlight Summary Report"
          f.puts "========================"
          f.puts ""
          f.puts "App: #{report[:app_name]}"
          f.puts "Generated: #{report[:generated_at]}"
          f.puts ""
          f.puts "Statistics:"
          f.puts "-----------"
          f.puts "Total Testers: #{report[:total_testers]}"
          f.puts "Total Builds: #{report[:total_builds]}"
          f.puts ""
          
          if report[:builds].any?
            f.puts "Recent Builds:"
            f.puts "--------------"
            report[:builds].first(5).each do |build|
              f.puts "• v#{build[:version]} (ID: #{build[:build_id]})"
              f.puts "  Uploaded: #{build[:uploaded_date]}"
              f.puts "  Status: #{build[:processing_state]}"
              f.puts "  Expired: #{build[:expired]}"
              f.puts ""
            end
          end
          
          if report[:testers].any?
            f.puts "Testers:"
            f.puts "--------"
            report[:testers].each do |tester|
              f.puts "• #{tester[:email]}"
              f.puts "  Name: #{tester[:first_name]} #{tester[:last_name]}"
              f.puts "  Type: #{tester[:invite_type]}"
              f.puts "  Groups: #{tester[:beta_groups]}"
              f.puts ""
            end
          end
          
          if report[:reviews] && report[:reviews].any?
            f.puts ""
            f.puts "Recent Reviews:"
            f.puts "---------------"
            report[:reviews].first(5).each do |review|
              f.puts "• #{review[:title]} (#{review[:rating]}⭐)"
              f.puts "  #{review[:body]}"
              f.puts "  - #{review[:reviewer_nickname]}"
              f.puts ""
            end
          end
        end
        
        UI.success "📄 Summary saved to: #{summary_path}"
      end
      
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       description: "Bundle identifier",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :key_id,
                                       description: "App Store Connect API Key ID",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :issuer_id,
                                       description: "App Store Connect Issuer ID",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :key_filepath,
                                       description: "Path to .p8 key file",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       description: "Directory to save feedback",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: "Show detailed error messages",
                                       optional: true,
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       description: "App ID to use as fallback",
                                       optional: true,
                                       type: String)
        ]
      end
      
      def self.description
        "Fetch TestFlight testers and build information from App Store Connect"
      end
      
      def self.authors
        ["AI Assistant"]
      end
      
      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end 