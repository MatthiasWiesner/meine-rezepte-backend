require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'digest/sha1'
require 'base64'
require 'yaml'
require 'pry'
require 'sinatra/cross_origin'
require 'fileutils'


class Organization < ActiveRecord::Base
    has_many :users
    has_many :recipes
    validates :name, presence: true, uniqueness: true
end

class User < ActiveRecord::Base
    belongs_to :organization
    has_many :recipes, through: :organization
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true
end

class Recipe < ActiveRecord::Base
    belongs_to :organization
    has_many :users, through: :organization
    validates :title, presence: true, uniqueness: true
end


class App < Sinatra::Base
    @@base_path = '/var/www/html/meine-rezepte/public/images'

    helpers do
        def protect!
            unless authorized?
                response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
                throw(:halt, [401, "Not authorized\n"])
            end
        end

        def authorized?
            @auth ||=  Rack::Auth::Basic::Request.new(request.env)
            if @auth.provided? && @auth.basic? && @auth.credentials
                user, pass = @auth.credentials
                @auth_user = User.where(email: user.strip(), password: Base64.encode64(pass).strip()).take
                return @auth_user.present?
            end
        end
    end

    configure do
        enable :cross_origin
        enable :sessions
        set :session_secret, "secret"
    end

    before do
        response.headers['Access-Control-Allow-Origin'] = '*'
    end

    options "*" do
        response.headers["Allow"] = "GET, POST, OPTIONS, PUT, DELETE"
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, DELETE"
        response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept"
        response.headers["Access-Control-Allow-Origin"] = "*"
        200
    end

    get "/" do
        content_type :json
        {:das => 'ist ein test'}.to_json
    end

    get '/recipe/?' do
        protect!
        content_type :json

        if params.key?("titleStart")
            t = params[:titleStart][0]
            if not t
                halt 500, "Missing parameter"
            end
            @recipes = @auth_user.recipes.where("title LIKE ?", "#{t}%")
        elsif params.key?("title")
            t = Base64.decode64(params[:title])
            if not t
                halt 500, "Missing parameter"
            end
            @recipes = @auth_user.recipes.where("title = ?", t).first
        else
            @recipes = @auth_user.recipes.all()
        end
        @recipes.to_json
    end

    get '/recipe/:id' do
        protect!
        content_type :json
        @recipe = @auth_user.recipes.find(params[:id])
        @recipe.to_json
    end

    post "/recipe/?" do
        protect!
        content_type :json
        begin
            @recipe = @auth_user.organization.recipes.create!(
                title: params[:title],
                description: params[:description],
                content: params[:content]
            )
            @recipe.to_json
        rescue => err
            halt 500, err.message
        end
    end

    put "/recipe/:id" do
        protect!
        content_type :json
        begin
            @recipe = @auth_user.recipes.find(params[:id])
            @recipe.update!(
                title: params[:title],
                description: params[:description],
                content: params[:content]
            )
            @recipe.to_json
        rescue => err
            halt 500, err.message
        end
    end

    delete '/recipe/:id' do
        protect!
        @recipe = @auth_user.recipes.find(params[:id])
        begin
            @recipe.pictureList.each do |picture_path|
                FileUtils.rm(File.join(@@base_path, picture_path))
            end
            @recipe.destroy!
        rescue => err
            halt 500, err.message
        end
    end

    ## Picture relevant methods
    post '/recipe/:id/picture' do
        protect!
        content_type :json
        '''
        params => 
        {
            "upload"=>
                {
                    "filename"=>"blobby.txt",
                    "type"=>"image/png",
                    "name"=>"upload",
                    "tempfile"=>#<File:/var/folders/r5/6pmr36k51xv68rpzmdhvb4nc0000h1/T/RackMultipart20180517-69893-1uky43m.txt>,
                    "head"=>"Content-Disposition: form-data; name=\"upload\"; filename=\"blobby.txt\"\r\nContent-Type: image/png\r\n"
            },
            "id"=>"2"
        }
        '''
        begin
            @recipe = @auth_user.recipes.find(params[:id])
            if not @recipe
                halt 404
            end

            halt 500, 'Wrong picture format' unless ['image/png', 'image/jpeg', 'image/gif'].include?(params[:upload][:type])
            halt 500, 'Missing file' unless params[:upload][:tempfile]

            tmp_path = params[:upload][:tempfile].path

            ext =  params[:upload][:type].split('/').last
            picture_name = File.basename(tmp_path, File.extname(tmp_path)).split('RackMultipart').last + '.' + ext
            organame = Base64.encode64(@auth_user.organization.name)[0..8]
            picture_path = File.join(organame, picture_name)

            dir_path = File.join(@@base_path, organame)
            FileUtils.mkdir_p(dir_path)
            FileUtils.chmod(0775, dir_path)

            full_path = File.join(dir_path, picture_name)
            FileUtils.mv(tmp_path, full_path)
            FileUtils.chmod(0664, full_path)

            @recipe.pictureList << picture_path
            @recipe.save!

            @recipe.to_json
        rescue => err
            halt 500, err.message
        end
    end

    delete '/recipe/:id/picture/:url' do
        protect!
        begin
            @recipe = @auth_user.recipes.find(params[:id])
            if not @recipe
                halt 404
            end
            picture_path = Base64.decode64(params[:url])
            FileUtils.rm(File.join(@@base_path, picture_path))
            @recipe.pictureList.delete(path)
            @recipe.save!
        rescue => err
            halt 500, err.message
        end
    end
end