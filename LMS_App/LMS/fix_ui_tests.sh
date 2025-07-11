#!/bin/bash

# Fix isEmpty issues in UI tests

echo "Fixing isEmpty usage in UI tests..."

# UITestBase.swift - keyboards.isEmpty
sed -i '' 's/!app\.keyboards\.isEmpty/app.keyboards.count > 0/g' LMSUITests/Helpers/UITestBase.swift

# DebugUITest.swift
sed -i '' 's/!app\.tabBars\.isEmpty/app.tabBars.count > 0/g' LMSUITests/DebugUITest.swift

# NavigationUITests.swift
sed -i '' 's/!coursesList\.cells\.isEmpty/coursesList.cells.count > 0/g' LMSUITests/Common/NavigationUITests.swift
sed -i '' 's/!testsList\.cells\.isEmpty/testsList.cells.count > 0/g' LMSUITests/Common/NavigationUITests.swift

# CourseMaterialsUITests.swift
sed -i '' 's/!coursesTable\.cells\.isEmpty/coursesTable.cells.count > 0/g' LMSUITests/CourseMaterialsUITests.swift
sed -i '' 's/!urlFields\.isEmpty/urlFields.count > 0/g' LMSUITests/CourseMaterialsUITests.swift

# SimpleSmokeTest.swift
sed -i '' 's/!app\.buttons\.isEmpty/app.buttons.count > 0/g' LMSUITests/SimpleSmokeTest.swift
sed -i '' 's/!app\.staticTexts\.isEmpty/app.staticTexts.count > 0/g' LMSUITests/SimpleSmokeTest.swift
sed -i '' 's/!app\.images\.isEmpty/app.images.count > 0/g' LMSUITests/SimpleSmokeTest.swift

# QuickStateTest.swift
sed -i '' 's/!tabBar\.buttons\.isEmpty/tabBar.buttons.count > 0/g' LMSUITests/QuickStateTest.swift
sed -i '' 's/!app\.buttons\.isEmpty/app.buttons.count > 0/g' LMSUITests/QuickStateTest.swift
sed -i '' 's/!app\.staticTexts\.isEmpty/app.staticTexts.count > 0/g' LMSUITests/QuickStateTest.swift
sed -i '' 's/!app\.textFields\.isEmpty/app.textFields.count > 0/g' LMSUITests/QuickStateTest.swift

# AdaptedUITests.swift
sed -i '' 's/!app\.buttons\.isEmpty/app.buttons.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!app\.staticTexts\.isEmpty/app.staticTexts.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!app\.tabBars\.isEmpty/app.tabBars.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!app\.scrollViews\.isEmpty/app.scrollViews.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!app\.collectionViews\.isEmpty/app.collectionViews.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!scrollView\.buttons\.isEmpty/scrollView.buttons.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!app\.navigationBars\.isEmpty/app.navigationBars.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!app\.images\.isEmpty/app.images.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!app\.cells\.isEmpty/app.cells.count > 0/g' LMSUITests/AdaptedUITests.swift
sed -i '' 's/!collection\.buttons\.isEmpty/collection.buttons.count > 0/g' LMSUITests/AdaptedUITests.swift

# CompetencyManagementUITests.swift
sed -i '' 's/!matrixCells\.isEmpty/matrixCells.count > 0/g' LMSUITests/CompetencyManagementUITests.swift

# PositionManagementUITests.swift
sed -i '' 's/!app\.collectionViews\.cells\.isEmpty/app.collectionViews.cells.count > 0/g' LMSUITests/PositionManagementUITests.swift

# ComprehensiveUITests.swift
sed -i '' 's/!app\.images\.isEmpty/app.images.count > 0/g' LMSUITests/ComprehensiveUITests.swift
sed -i '' 's/!app\.cells\.isEmpty/app.cells.count > 0/g' LMSUITests/ComprehensiveUITests.swift
sed -i '' 's/!app\.switches\.isEmpty/app.switches.count > 0/g' LMSUITests/ComprehensiveUITests.swift

# AnalyticsUITests.swift
sed -i '' 's/!app\.tables\[\"courseCompletionReportTable\"\]\.cells\.isEmpty/app.tables["courseCompletionReportTable"].cells.count > 0/g' LMSUITests/Analytics/AnalyticsUITests.swift

# LoginUITests.swift
sed -i '' 's/!app\.keyboards\.isEmpty/app.keyboards.count > 0/g' LMSUITests/Authentication/LoginUITests.swift

# Tests/TestTakingUITests.swift
sed -i '' 's/!answerOptions\.isEmpty/answerOptions.count > 0/g' LMSUITests/Tests/TestTakingUITests.swift

echo "Fixing completed!" 