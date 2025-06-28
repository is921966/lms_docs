module Fastlane
  module Actions
    class FetchTestflightFeedbackAction < Action
      def self.run(params)
        require 'spaceship'
        require 'json'
        require 'fileutils'
        
        UI.message "🚀 Fetching TestFlight feedback..."
        
        begin
          # Authenticate with App Store Connect
          Spaceship::ConnectAPI.auth(key_id: params[:key_id], 
                                    issuer_id: params[:issuer_id], 
                                    key_filepath: params[:key_filepath])
          
          UI.success "✅ Successfully authenticated with App Store Connect"
          
          # Get app
          app = Spaceship::ConnectAPI::App.find(params[:app_identifier])
          
          if app.nil?
            UI.error "❌ App not found: #{params[:app_identifier]}"
            return 0
          end
          
          # Create output directory
          output_dir = params[:output_directory] || "testflight_feedback"
          FileUtils.mkdir_p(output_dir)
          FileUtils.mkdir_p("#{output_dir}/screenshots")
          
          # Get beta feedback
          feedbacks = app.get_beta_feedback || []
          
          # Create report
          report = {
            app_identifier: params[:app_identifier],
            generated_at: Time.now.iso8601,
            total_count: feedbacks.count,
            feedbacks: []
          }
          
          # Process each feedback
          feedbacks.each_with_index do |feedback, index|
            UI.message "Processing feedback #{index + 1}/#{feedbacks.count}..."
            
            feedback_data = {
              id: feedback.id,
              tester_email: feedback.tester_email || "Unknown",
              comment: feedback.comment || "",
              timestamp: feedback.timestamp,
              build_version: feedback.build_version,
              device_model: feedback.device_model,
              os_version: feedback.os_version,
              screenshots: []
            }
            
            # Download screenshots if available
            if feedback.screenshots && !feedback.screenshots.empty?
              feedback.screenshots.each_with_index do |screenshot, screenshot_index|
                filename = "feedback_#{feedback.id}_screenshot_#{screenshot_index}.png"
                filepath = "#{output_dir}/screenshots/#{filename}"
                
                begin
                  File.write(filepath, screenshot.download)
                  feedback_data[:screenshots] << filename
                  UI.success "Downloaded screenshot: #{filename}"
                rescue => e
                  UI.error "Failed to download screenshot: #{e.message}"
                end
              end
            end
            
            report[:feedbacks] << feedback_data
            
            # Check for critical feedback
            if params[:create_github_issues] && is_critical_feedback?(feedback)
              create_github_issue(feedback, params)
            end
          end
          
          # Save report
          report_path = "#{output_dir}/feedback_report.json"
          File.write(report_path, JSON.pretty_generate(report))
          UI.success "📊 Report saved to: #{report_path}"
          
          # Print summary
          UI.message ""
          UI.message "=== TestFlight Feedback Summary ==="
          UI.message "Total feedback: #{feedbacks.count}"
          UI.message "Critical issues: #{report[:feedbacks].count { |f| is_critical_text?(f[:comment]) }}"
          UI.message "Screenshots collected: #{report[:feedbacks].sum { |f| f[:screenshots].count }}"
          
          return feedbacks.count
          
        rescue => e
          UI.error "❌ Error fetching feedback: #{e.message}"
          UI.error e.backtrace.join("\n") if params[:verbose]
          return 0
        end
      end
      
      def self.is_critical_feedback?(feedback)
        is_critical_text?(feedback.comment)
      end
      
      def self.is_critical_text?(text)
        return false if text.nil? || text.empty?
        
        critical_keywords = ['crash', 'critical', 'urgent', 'broken', 'не работает', 'падает', 'критично']
        text.downcase.match?(Regexp.union(critical_keywords))
      end
      
      def self.create_github_issue(feedback, params)
        return unless params[:github_token] && params[:github_repo]
        
        require 'net/http'
        require 'uri'
        
        uri = URI("https://api.github.com/repos/#{params[:github_repo]}/issues")
        
        issue_data = {
          title: "🚨 Critical TestFlight Feedback from #{feedback.tester_email}",
          body: generate_issue_body(feedback),
          labels: ['testflight-feedback', 'critical', 'bug']
        }
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "token #{params[:github_token]}"
        request['Content-Type'] = 'application/json'
        request.body = JSON.generate(issue_data)
        
        response = http.request(request)
        
        if response.code == '201'
          UI.success "Created GitHub issue for critical feedback"
        else
          UI.error "Failed to create GitHub issue: #{response.code} - #{response.body}"
        end
      end
      
      def self.generate_issue_body(feedback)
        <<~BODY
        ## TestFlight Feedback
        
        **From:** #{feedback.tester_email || 'Unknown'}
        **Date:** #{feedback.timestamp}
        **Build:** #{feedback.build_version}
        **Device:** #{feedback.device_model} (iOS #{feedback.os_version})
        
        ## Comment
        #{feedback.comment}
        
        ## Screenshots
        #{feedback.screenshots&.count || 0} screenshot(s) attached
        
        ---
        *Automatically created from TestFlight feedback*
        BODY
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
                                       description: "Directory to save feedback and screenshots",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :create_github_issues,
                                       description: "Create GitHub issues for critical feedback",
                                       optional: true,
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :github_token,
                                       description: "GitHub personal access token",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :github_repo,
                                       description: "GitHub repository (owner/repo)",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: "Show detailed error messages",
                                       optional: true,
                                       is_string: false,
                                       default_value: false)
        ]
      end
      
      def self.description
        "Fetch TestFlight feedback and screenshots from App Store Connect"
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