//
//  SpaccesConnector.swift
//  DO_S3
//
//  Created by Andrey on 14.10.2021.
//

import Foundation
import AWSS3

private enum SpacesRegion: String {
    case sfo = "sfo2", ams = "ams3", sgp = "sgp1", fra = "fra1"
    // Равзернут нв fra1
    
    var endpointUrl: String {
        return "https://\(self.rawValue).digitaloceanspaces.com"
    }
}

// TODO: Вынести ключи в .env????
struct SpacesRepository {
    private static let accessKey = "" //DO Access key (первый ключ)
    private static let secretKey = "" //DO Secret key (второй ключ)
    private static let bucket = "space-pf-space"
    
    // TODO: Нужна отдельная функция для получения списка необходимых файлов с бека
    private let fileName = "example-image" 
    
    private var transferUtility: AWSS3TransferUtility?
    
    init(){
        let credential = AWSStaticCredentialsProvider(accessKey: SpacesRepository.accessKey, secretKey: SpacesRepository.secretKey)
        let regionEndpoint = AWSEndpoint(urlString: SpacesRegion.fra.endpointUrl) // Выбран Франкфурт
        
        let configuration = AWSServiceConfiguration(region: .USEast1, endpoint: regionEndpoint, credentialsProvider: credential) // Тут регион AWS не важен
        
        let transferConfiguration = AWSS3TransferUtilityConfiguration()
        transferConfiguration.isAccelerateModeEnabled = false
        transferConfiguration.bucket = SpacesRepository.bucket
        
        AWSS3TransferUtility.register(with: configuration!, transferUtilityConfiguration: transferConfiguration, forKey: SpacesRepository.bucket)
        transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: SpacesRepository.bucket)
    }
    
    func uploadExampleFile(){
        guard let exampleImage = Bundle.main.url(forResource: fileName, withExtension: "jpg") else {
            print("Not found")
            return
        }
        
        
        transferUtility?.uploadFile(exampleImage, key: fileName, contentType: "image/jpg", expression: nil, completionHandler: { task, error in
            guard error == nil else {
                print("S3 Upload Error: \(error!.localizedDescription)")
                return
            }
            print("S3 Upload Completed")
        }).continueWith(block: {(task) -> Any? in
           print("Upload Started")
            return nil
        })
    }
    
    func downloadExampleFile(comletition: @escaping ((Data?, Error?) -> Void)){
        transferUtility?.downloadData(forKey: fileName, expression: nil, completionHandler: {(task, url, data, error) in
            guard error == nil else {
                print("S3 Download error: \(error!.localizedDescription)")
                comletition(nil, error)
                return
            }
            print("S3 Download Completed")
            comletition(data, nil)
        }).continueWith(block: { (task) -> Any? in
            print("S3 Download Starting")
            return nil
        })
    }
}

