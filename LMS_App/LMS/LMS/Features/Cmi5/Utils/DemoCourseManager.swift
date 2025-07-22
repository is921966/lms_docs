//
//  DemoCourseManager.swift
//  LMS
//
//  Created on Sprint 40 - Demo Course Management
//

import Foundation
import ZIPFoundation

/// Менеджер для работы с демо-курсами
class DemoCourseManager {
    
    static let shared = DemoCourseManager()
    
    private init() {}
    
    /// Директория для хранения демо-курсов в Documents
    private var demoCourseDirectory: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("DemoCourses", isDirectory: true)
    }
    
    /// Проверяет и создает директорию для демо-курсов
    func setupDemoCourseDirectory() {
        guard let directory = demoCourseDirectory else { return }
        
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
    
    /// Копирует демо-курсы из bundle в Documents при первом запуске
    func copyDemoCoursesToDocuments() {
        setupDemoCourseDirectory()
        
        guard let documentsDir = demoCourseDirectory else {
            print("❌ Could not get documents directory")
            return
        }
        
        // Список демо-курсов для копирования
        let demoCourses = [
            "ai_fluency_course_v1.0",
            "single_au_basic_responsive",
            "masteryscore_responsive",
            "multi_au_framed",
            "pre_post_test_framed"
        ]
        
        for courseName in demoCourses {
            copyDemoCourse(named: courseName, to: documentsDir)
        }
    }
    
    /// Копирует один демо-курс
    private func copyDemoCourse(named name: String, to directory: URL) {
        // Сначала пробуем найти в корне Resources
        var sourceURL: URL?
        
        if let path = Bundle.main.path(forResource: name, ofType: "zip") {
            sourceURL = URL(fileURLWithPath: path)
        }
        // Если не найден, пробуем в подпапке CatapultDemoCourses
        else if let catapultURL = Bundle.main.url(forResource: "CatapultDemoCourses", withExtension: nil) {
            let fileURL = catapultURL.appendingPathComponent("\(name).zip")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                sourceURL = fileURL
            }
        }
        
        guard let source = sourceURL else {
            print("⚠️ Demo course not found in bundle: \(name)")
            return
        }
        
        let destinationURL = directory.appendingPathComponent("\(name).zip")
        
        // Проверяем, не скопирован ли уже файл
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("ℹ️ Demo course already exists: \(name)")
            return
        }
        
        do {
            try FileManager.default.copyItem(at: source, to: destinationURL)
            print("✅ Copied demo course: \(name)")
        } catch {
            print("❌ Failed to copy demo course \(name): \(error)")
        }
    }
    
    /// Возвращает URL демо-курса в Documents
    func getDocumentsURL(for demoCourse: DemoCourse) -> URL? {
        guard let directory = demoCourseDirectory else { return nil }
        
        let fileURL = directory.appendingPathComponent("\(demoCourse.filename).zip")
        
        // Если файл не существует в Documents, пробуем скопировать из bundle
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            copyDemoCourse(named: demoCourse.filename, to: directory)
        }
        
        // Проверяем еще раз
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        return nil
    }
    
    /// Возвращает URL демо-курса из bundle (fallback)
    func getBundleURL(for demoCourse: DemoCourse) -> URL? {
        print("🔍 [DemoCourseManager] Looking for demo course in bundle: \(demoCourse.filename)")
        
        let bundlePath: String?
        
        if demoCourse.filename == "ai_fluency_course_v1.0" {
            // AI Fluency course is in Resources root
            bundlePath = Bundle.main.path(forResource: demoCourse.filename, ofType: "zip")
            print("   - Checking Resources root for AI Fluency course")
        } else {
            // CATAPULT courses are in CatapultDemoCourses subfolder
            // Сначала пробуем найти просто по имени файла
            bundlePath = Bundle.main.path(forResource: demoCourse.filename, ofType: "zip")
            print("   - Checking Resources root for CATAPULT course")
            
            // Если не найден, пробуем с префиксом CatapultDemoCourses
            if bundlePath == nil {
                if let catapultURL = Bundle.main.url(forResource: "CatapultDemoCourses", withExtension: nil) {
                    let fileURL = catapultURL.appendingPathComponent("\(demoCourse.filename).zip")
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        print("✅ [DemoCourseManager] Found in CatapultDemoCourses folder at: \(fileURL.path)")
                        return fileURL
                    }
                }
            }
        }
        
        if let path = bundlePath {
            print("✅ [DemoCourseManager] Found in bundle at: \(path)")
            return URL(fileURLWithPath: path)
        } else {
            print("❌ [DemoCourseManager] Not found in bundle")
            
            // Дополнительная диагностика - проверим что есть в bundle
            print("📂 [DemoCourseManager] Available resources in bundle:")
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    for item in contents.prefix(20) { // Показываем первые 20 файлов
                        print("   - \(item)")
                    }
                    if contents.count > 20 {
                        print("   ... and \(contents.count - 20) more files")
                    }
                    
                    // Проверяем наличие папки CatapultDemoCourses
                    let catapultPath = (resourcePath as NSString).appendingPathComponent("CatapultDemoCourses")
                    if FileManager.default.fileExists(atPath: catapultPath) {
                        print("📂 [DemoCourseManager] Found CatapultDemoCourses folder, contents:")
                        let catapultContents = try FileManager.default.contentsOfDirectory(atPath: catapultPath)
                        for file in catapultContents {
                            print("   - \(file)")
                        }
                    }
                } catch {
                    print("   ❌ Could not list bundle contents: \(error)")
                }
            }
        }
        
        return nil
    }
    
    /// Создает временный файл для демо-курса (для тестирования)
    func createTemporaryDemoCourse(for demoCourse: DemoCourse) -> URL? {
        // Создаем временную директорию
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("DemoCourses", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        let tempFile = tempDir.appendingPathComponent("\(demoCourse.filename).zip")
        
        // Создаем простой ZIP с минимальной структурой Cmi5
        let manifest = """
        <?xml version="1.0" encoding="UTF-8"?>
        <courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/coursestructure.xsd">
            <course id="\(demoCourse.filename)">
                <title>
                    <langstring lang="ru">\(demoCourse.name)</langstring>
                    <langstring lang="en">\(demoCourse.name)</langstring>
                </title>
                <description>
                    <langstring lang="ru">\(demoCourse.description)</langstring>
                    <langstring lang="en">\(demoCourse.description)</langstring>
                </description>
                <au id="au_1">
                    <title>
                        <langstring lang="ru">Модуль 1</langstring>
                        <langstring lang="en">Module 1</langstring>
                    </title>
                    <url>index.html</url>
                </au>
            </course>
        </courseStructure>
        """
        
        let indexHtml = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>\(demoCourse.name)</title>
        </head>
        <body>
            <h1>\(demoCourse.name)</h1>
            <p>\(demoCourse.description)</p>
        </body>
        </html>
        """
        
        do {
            // Создаем простой ZIP архив с использованием ZIPFoundation
            let archive = try Archive(url: tempFile, accessMode: .create)
            
            // Добавляем файлы в архив
            let manifestData = manifest.data(using: .utf8)!
            try archive.addEntry(with: "cmi5.xml", type: .file, uncompressedSize: UInt32(manifestData.count), provider: { position, size in
                return manifestData.subdata(in: Int(position)..<Int(position + size))
            })
            
            let indexData = indexHtml.data(using: .utf8)!
            try archive.addEntry(with: "index.html", type: .file, uncompressedSize: UInt32(indexData.count), provider: { position, size in
                return indexData.subdata(in: Int(position)..<Int(position + size))
            })
            
            return tempFile
        } catch {
            print("❌ Failed to create temporary demo course: \(error)")
        }
        
        return nil
    }
} 