//
//  StoriesData.swift
//  Stories
//
//  Created by alc on 10.06.2021.
//

import Foundation

struct Profile: Codable{
    let username:String
    let profilePicUrl:String
    let storyCount: Int
    var storiesSeenCount:Int
    let stories: [Story]
}

struct Story: Codable {
    let storyId: Int
    let contentType: Int
    let contentUrl: String
    let timestamp: String
}

struct Profiles: Codable {
    let profiles: [Profile]
}
