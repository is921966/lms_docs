import Foundation

enum AccessibilityIdentifiers {
    
    // MARK: - Authentication
    enum Auth {
        static let emailField = "loginEmailField"
        static let passwordField = "loginPasswordField"
        static let loginButton = "loginButton"
        static let rememberMeToggle = "rememberMeToggle"
        static let errorLabel = "loginErrorLabel"
    }
    
    // MARK: - Courses
    enum Courses {
        static let coursesList = "coursesList"
        static let courseCell = "courseCell"
        static let searchField = "coursesSearchField"
        static let filterButton = "coursesFilterButton"
        static let addCourseButton = "addCourseButton"
        static let courseTitleField = "courseTitleField"
        static let courseDescriptionField = "courseDescriptionField"
        static let saveCourseButton = "saveCourseButton"
        static let cancelButton = "courseCancelButton"
        static let enrollButton = "courseEnrollButton"
    }
    
    // MARK: - Tests
    enum Tests {
        static let testsList = "testsList"
        static let testCell = "testCell"
        static let startTestButton = "startTestButton"
        static let nextQuestionButton = "nextQuestionButton"
        static let previousQuestionButton = "previousQuestionButton"
        static let submitTestButton = "submitTestButton"
        static let bookmarkButton = "bookmarkQuestionButton"
        static let answerOption = "answerOption"
        static let testResultView = "testResultView"
    }
    
    // MARK: - Competencies
    enum Competencies {
        static let competenciesList = "competenciesList"
        static let competencyCell = "competencyCell"
        static let addCompetencyButton = "addCompetencyButton"
        static let competencyNameField = "competencyNameField"
        static let competencyLevelSlider = "competencyLevelSlider"
        static let assessButton = "assessCompetencyButton"
    }
    
    // MARK: - Onboarding
    enum Onboarding {
        static let onboardingView = "onboardingView"
        static let stepIndicator = "onboardingStepIndicator"
        static let nextStepButton = "nextStepButton"
        static let skipButton = "skipStepButton"
        static let taskCell = "onboardingTaskCell"
        static let completeTaskButton = "completeTaskButton"
        static let uploadButton = "uploadDocumentButton"
    }
    
    // MARK: - Analytics
    enum Analytics {
        static let dashboardView = "analyticsDashboard"
        static let reportsList = "reportsList"
        static let generateReportButton = "generateReportButton"
        static let dateRangePicker = "dateRangePicker"
        static let exportButton = "exportReportButton"
        static let chartView = "analyticsChartView"
    }
    
    // MARK: - Profile
    enum Profile {
        static let profileView = "profileView"
        static let editButton = "editProfileButton"
        static let nameField = "profileNameField"
        static let emailField = "profileEmailField"
        static let saveButton = "saveProfileButton"
        static let logoutButton = "logoutButton"
        static let settingsButton = "settingsButton"
    }
    
    // MARK: - Common
    enum Common {
        static let tabBar = "mainTabBar"
        static let loadingIndicator = "loadingIndicator"
        static let errorView = "errorView"
        static let retryButton = "retryButton"
        static let searchBar = "globalSearchBar"
        static let emptyStateView = "emptyStateView"
    }
} 