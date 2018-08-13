//
//  Constants.swift
//  PostsApp
//

import Foundation
import AWSAppSync

/*let StaticAPIKey = "da2-ipgwjh3igbavnlawp45zzhaxw4"

// The Endpoint URL for AppSync
let AppSyncEndpointURL: URL = URL(string: "https://p2lcyijmrfdg5aqcjw5di2hoba.appsync-api.eu-central-1.amazonaws.com/graphql")!

let AppSyncRegion: AWSRegionType = .EUCentral1
let database_name = "PostTable"


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
