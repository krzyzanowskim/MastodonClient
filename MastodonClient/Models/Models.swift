import Foundation
import Combine

// MARK: - Account
struct Account: Codable, Identifiable {
    let id: String
    let username: String
    let displayName: String
    let locked: Bool
    let bot: Bool
    let createdAt: String
    let note: String
    let url: String
    let avatar: String
    let avatarStatic: String
    let header: String
    let headerStatic: String
    let followersCount: Int
    let followingCount: Int
    let statusesCount: Int
    let lastStatusAt: String?
    let fields: [Field]?
    let emojis: [Emoji]?
    
    enum CodingKeys: String, CodingKey {
        case id, username, locked, bot, note, url, avatar, header, fields, emojis
        case displayName = "display_name"
        case createdAt = "created_at"
        case avatarStatic = "avatar_static"
        case headerStatic = "header_static"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case statusesCount = "statuses_count"
        case lastStatusAt = "last_status_at"
    }
}

// MARK: - Status
class Status: Codable, Identifiable, ObservableObject {
    let id: String
    let createdAt: String
    let inReplyToId: String?
    let inReplyToAccountId: String?
    let sensitive: Bool
    let spoilerText: String
    let visibility: String
    let language: String?
    let uri: String
    let url: String?
    let repliesCount: Int
    let reblogsCount: Int
    let favouritesCount: Int
    let favourited: Bool?
    let reblogged: Bool?
    let muted: Bool?
    let bookmarked: Bool?
    let content: String
    let reblog: Status?
    let account: Account
    let mediaAttachments: [MediaAttachment]
    let mentions: [Mention]
    let tags: [Tag]
    let emojis: [Emoji]
    let card: Card?
    let poll: Poll?
    
    enum CodingKeys: String, CodingKey {
        case id, sensitive, visibility, language, uri, url, content, reblog, account, mentions, tags, emojis, card, poll
        case createdAt = "created_at"
        case inReplyToId = "in_reply_to_id"
        case inReplyToAccountId = "in_reply_to_account_id"
        case spoilerText = "spoiler_text"
        case repliesCount = "replies_count"
        case reblogsCount = "reblogs_count"
        case favouritesCount = "favourites_count"
        case favourited, reblogged, muted, bookmarked
        case mediaAttachments = "media_attachments"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        inReplyToId = try container.decodeIfPresent(String.self, forKey: .inReplyToId)
        inReplyToAccountId = try container.decodeIfPresent(String.self, forKey: .inReplyToAccountId)
        sensitive = try container.decode(Bool.self, forKey: .sensitive)
        spoilerText = try container.decode(String.self, forKey: .spoilerText)
        visibility = try container.decode(String.self, forKey: .visibility)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        uri = try container.decode(String.self, forKey: .uri)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        repliesCount = try container.decode(Int.self, forKey: .repliesCount)
        reblogsCount = try container.decode(Int.self, forKey: .reblogsCount)
        favouritesCount = try container.decode(Int.self, forKey: .favouritesCount)
        favourited = try container.decodeIfPresent(Bool.self, forKey: .favourited)
        reblogged = try container.decodeIfPresent(Bool.self, forKey: .reblogged)
        muted = try container.decodeIfPresent(Bool.self, forKey: .muted)
        bookmarked = try container.decodeIfPresent(Bool.self, forKey: .bookmarked)
        content = try container.decode(String.self, forKey: .content)
        reblog = try container.decodeIfPresent(Status.self, forKey: .reblog)
        account = try container.decode(Account.self, forKey: .account)
        mediaAttachments = try container.decode([MediaAttachment].self, forKey: .mediaAttachments)
        mentions = try container.decode([Mention].self, forKey: .mentions)
        tags = try container.decode([Tag].self, forKey: .tags)
        emojis = try container.decode([Emoji].self, forKey: .emojis)
        card = try container.decodeIfPresent(Card.self, forKey: .card)
        poll = try container.decodeIfPresent(Poll.self, forKey: .poll)
    }
}

// MARK: - MediaAttachment
struct MediaAttachment: Codable, Identifiable {
    let id: String
    let type: String
    let url: String
    let previewUrl: String
    let remoteUrl: String?
    let description: String?
    let blurhash: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, url, description, blurhash
        case previewUrl = "preview_url"
        case remoteUrl = "remote_url"
    }
}

// MARK: - Mention
struct Mention: Codable {
    let id: String
    let username: String
    let url: String
    let acct: String
}

// MARK: - Tag
struct Tag: Codable {
    let name: String
    let url: String
}

// MARK: - Emoji
struct Emoji: Codable {
    let shortcode: String
    let url: String
    let staticUrl: String
    let visibleInPicker: Bool
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case shortcode, url, category
        case staticUrl = "static_url"
        case visibleInPicker = "visible_in_picker"
    }
}

// MARK: - Field
struct Field: Codable {
    let name: String
    let value: String
    let verifiedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name, value
        case verifiedAt = "verified_at"
    }
}

// MARK: - Card
struct Card: Codable {
    let url: String
    let title: String
    let description: String
    let type: String
    let authorName: String?
    let authorUrl: String?
    let providerName: String?
    let providerUrl: String?
    let html: String?
    let width: Int?
    let height: Int?
    let image: String?
    let embedUrl: String?
    let blurhash: String?
    
    enum CodingKeys: String, CodingKey {
        case url, title, description, type, html, width, height, image, blurhash
        case authorName = "author_name"
        case authorUrl = "author_url"
        case providerName = "provider_name"
        case providerUrl = "provider_url"
        case embedUrl = "embed_url"
    }
}

// MARK: - Poll
struct Poll: Codable {
    let id: String
    let expiresAt: String?
    let expired: Bool
    let multiple: Bool
    let votesCount: Int
    let votersCount: Int?
    let voted: Bool?
    let ownVotes: [Int]?
    let options: [PollOption]
    let emojis: [Emoji]
    
    enum CodingKeys: String, CodingKey {
        case id, expired, multiple, voted, options, emojis
        case expiresAt = "expires_at"
        case votesCount = "votes_count"
        case votersCount = "voters_count"
        case ownVotes = "own_votes"
    }
}

// MARK: - PollOption
struct PollOption: Codable {
    let title: String
    let votesCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case votesCount = "votes_count"
    }
}

// MARK: - Notification
struct MastodonNotification: Codable, Identifiable {
    let id: String
    let type: String
    let createdAt: String
    let account: Account
    let status: Status?
    
    enum CodingKeys: String, CodingKey {
        case id, type, account, status
        case createdAt = "created_at"
    }
}

// MARK: - Timeline Response
struct TimelineResponse: Codable {
    let statuses: [Status]
}

// MARK: - Search Results
struct SearchResults: Codable {
    let accounts: [Account]
    let statuses: [Status]
    let hashtags: [Tag]
}

// MARK: - Application
struct Application: Codable {
    let id: String
    let name: String
    let website: String?
    let redirectUri: String
    let clientId: String
    let clientSecret: String
    let vapidKey: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, website
        case redirectUri = "redirect_uri"
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case vapidKey = "vapid_key"
    }
}

// MARK: - Token
struct Token: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case scope
        case accessToken = "access_token"
        case tokenType = "token_type"
        case createdAt = "created_at"
    }
}

// MARK: - Instance
struct Instance: Codable {
    let uri: String
    let title: String
    let shortDescription: String
    let description: String
    let email: String
    let version: String
    let languages: [String]
    let registrations: Bool
    let approvalRequired: Bool
    let invitesEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case uri, title, description, email, version, languages, registrations
        case shortDescription = "short_description"
        case approvalRequired = "approval_required"
        case invitesEnabled = "invites_enabled"
    }
}