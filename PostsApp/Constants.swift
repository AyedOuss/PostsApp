//
//  Constants.swift
//  PostsApp
//

import Foundation
import AWSAppSync

/*let StaticAPIKey = "API key"

// The Endpoint URL for AppSync
let AppSyncEndpointURL: URL = URL(string: "")!

let AppSyncRegion: AWSRegionType = region
let database_name = "table name"


class APIKeyAuthProvider: AWSAPIKeyAuthProvider {
    func getAPIKey() -> String {
        // This function could dynamicall fetch the API Key if required and return it to AppSync client.
        return StaticAPIKey
    }
}
*/
let CognitoIdentityPoolId = "pool id"
let CognitoIdentityRegion: AWSRegionType = .EUCentral1
let AppSyncRegion: AWSRegionType = .EUCentral1
let AppSyncEndpointURL: URL = URL(string: "URL")!
let database_name = "database"
