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
require 'launchy'

module HackerNews

  class Database < SQLite3::Database
    include Singleton

    def initialize
      super('hacker_news.sqlite3')
      self.results_as_hash = true
      self.type_translation = true
    end

  end

  class Client
    attr_reader :stories, :users

    def initialize
      front_page_titles = Nokogiri::HTML(
                           RestClient.get('news.ycombinator.com')).css(
                                          'td.title > a')
      front_page_users = Nokogiri::HTML(
                          RestClient.get('news.ycombinator.com')).css(
                                         'td.subtext')
      @users = {}
      @stories = generate_story_objects(front_page_titles, front_page_users)
    end

    def run
      while true
        print_front_page
        print "Command? > "
        command = gets.chomp
        index = command[1..-1].strip.to_i-1
        case command[0]
        when 'o'
          Launchy.open(open_link(index))
        when 'q'
          break
        when 'c'
          if @stories[index].comments.empty?
            generate_comment_objects(index)
          end
          print_comments(index)
          print "<Press Enter to continue>"
          gets
        end
      end
    end

    def print_front_page
      puts
      puts " Hacker News Front Page ".center(93, '-')
      puts
      @stories.each_with_index do |story, index|
        print "#{(index+1).to_s.rjust(2, '0')}. "
        print "#{story.title[0...60].ljust(60, ' ')} | "
        print "#{story.user[0...20].rjust(20, ' ')} | "
        print "#{story.points}"
        puts
      end
      puts
    end

    def print_comments(index)
      puts
      puts " #{stories[index].title} ".center(93, '-')
      puts
      comments = @stories[index].comments
      comments.each_with_index do |comment, i|
        puts "#{(i+1).to_s.rjust(2, '0')}. #{comment.user}"
        puts "#{comment.body}".scan(/\S.{0,93}\S(?=\s|$)|\S+/)
        puts
      end
      puts
    end

    def open_link(index)
      "#{@stories[index].link}"
    end

    def generate_story_objects(titles, users)
      stories = []
      titles.each_with_index do |title, index|
        user_obj = users[index]
        t = title.children.text
        l = title.attributes['href'].value
        begin
          u = user_obj.children[2].text
          p = user_obj.children[0].text.to_i
          q = user_obj.children[4].attributes["href"].value
        rescue NoMethodError
          next
        end
        s = make_story(t, l, u, p, q)
        stories << s
        if @users[u]
          @users[u].stories << s
        else
          @users[u] = User.new(u)
          @users[u].stories << s
        end
      end
      stories
    end

    def open_comments(index)
      "http://news.ycombinator.com/#{@stories[index].page_query}"
    end

    def generate_comment_objects(index)
      comments_page = Nokogiri::HTML(
                       RestClient.get(open_comments(index))).css('td.default')
      comments_page.each do |comment|
        t = comment.children[2].children.text
        u = comment.children[0].children[0].children[0].text
        c = Comment.new(u, index, t)
        @stories[index].comments << c
        if @users[u]
          @users[u].comments << c
        else
          @users[u] = User.new(u)
          @users[u].comments << c
        end
      end
    end

    def make_story(title, link, user, points, page_query, comments = [])
      Story.new(title, link, user, points, page_query, comments)
    end
  end

  class Story
    attr_reader :title, :link, :user, :points, :page_query
    attr_accessor :comments

    def initialize(title, link, user, points, page_query, comments)
      @title, @link, @user = title, link, user
      @points, @page_query, @comments = points, page_query, comments
    end
  end

  class Comment
    attr_reader :user, :parent, :body

    def initialize (user, parent, body)
      @user, @parent, @body = user, parent, body
    end
  end

  class User
    attr_reader :name
    attr_accessor :karma, :stories, :comments

    def initialize(name)
      @name = name
      @karma = 0
      @stories = []
      @comments = []
    end
  end
end

# get links:
# Nokogiri::HTML(RestClient.get('news.ycombinator.com')).css('td.title > a').each { |link| @fr_user << link.attributes['href'].value }

# get titles:
# Nokogiri::HTML(RestClient.get('news.ycombinator.com')).css('td.title > a').each { |link| p link.children[0].text }