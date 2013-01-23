# query site for current top posts
# fetch link for such post
# ^comments thread
# list comments
# record users
# query for posts/comments of a users
# calc users's average karma

# def crawl_HN
# scan home page collecting post-data
# from post, collect user data (author)
# from post, collect comment data, creating user if .nil?
# end

require 'singleton'
require 'rest_client'
require 'addressable/uri'
require 'nokogiri'
require 'sqlite3'

module HackerNews

  class Database < SQLite3
    include Singleton

    def initialize
      super

    end

  end

  class Client

  end

end