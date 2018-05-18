require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'digest/sha1'
require 'base64'
require 'cloudinary'
require 'yaml'
require 'pry'


class Recipe < ActiveRecord::Base
    validates :title, presence: true, uniqueness: true
end

class User < ActiveRecord::Base
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true
end


class App < Sinatra::Base
    HTPASSWD_PATH = '.htpasswd'

    cloudinary_cfg = YAML.load_file('./config/cloudinary.yml')[Sinatra::Application.environment.to_s]
    Cloudinary.config(cloudinary_cfg)

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
                auth = User.where(email: user.strip(), password: Base64.encode64(pass).strip())
                return auth.present?
            end
        end
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
            @recipes = Recipe.where("title LIKE ?", "#{t}%")
        elsif params.key?("title")
            t = params[:title]
            if not t
                halt 500, "Missing parameter"
            end
            @recipes = Recipe.where("title = ?", t)[0]
        else
            @recipes = Recipe.all()
        end
        @recipes.to_json
    end

    get '/recipe/:id' do
        protect!
        content_type :json
        @recipe = Recipe.find(params[:id])
        @recipe.to_json
    end

    post "/recipe/?" do
        protect!
        payload = params 
        payload = JSON.parse(request.body.read).symbolize_keys

        begin
            @recipe = Recipe.create!(payload)
            @recipe.to_json
        rescue => err
            halt 500, err.message
        end
    end

    put "/recipe/:id" do
        protect!
        payload = params
        payload = JSON.parse(request.body.read).symbolize_keys

        begin
            @recipe = Recipe.find(params[:id])
            @recipe.update_attributes!(payload)
            @recipe.to_json
        rescue => err
            halt 500, err.message
        end
    end

    delete '/recipe/:id' do
        protect!
        begin
            Recipe.destroy(params[:id])
        rescue => err
            halt 500, err.message
        end
    end

    ## Picture relevant methods
    post '/recipe/:id/picture' do
        protect!
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
            @recipe = Recipe.find(params[:id])
            if not @recipe
                halt 404
            end
            
            halt 500, 'Wrong picture format' unless ['image/png', 'image/jpeg', 'image/gif'].include?(params[:upload][:type])
            halt 500, 'Missing file' unless params[:upload][:tempfile]

            result = Cloudinary::Uploader.upload(params[:upload][:tempfile])
            '''
            {
                "public_id"=>"macx14urgihbton1dggx", 
                "version"=>1526560741, 
                "signature"=>"3ffd79ed4b402567c4e5c7cd98a5aa2e31c86791", 
                "width"=>350, 
                "height"=>350, 
                "format"=>"png", 
                "resource_type"=>"image", 
                "created_at"=>"2018-05-17T12:39:01Z", 
                "tags"=>[], 
                "bytes"=>78661, 
                "type"=>"upload", 
                "etag"=>"016776bd6dd30cbc7547110dbdf27887", 
                "placeholder"=>false, 
                "url"=>"http://res.cloudinary.com/dudvseir8/image/upload/v1526560741/macx14urgihbton1dggx.png", "secure_url"=>"https://res.cloudinary.com/dudvseir8/image/upload/v1526560741/macx14urgihbton1dggx.png", "original_filename"=>"RackMultipart20180517-76738-1uo0000", 
                "original_extension"=>"txt"
            }
            '''
            if not @recipe.pictureList
                @recipe.pictureList = []
            end
            @recipe.pictureList << result["secure_url"]
            @recipe.save!

            result.to_json
        rescue => err
            halt 500, err.message
        end
    end

    delete '/recipe/:id/picture/:url' do
        protect!
        begin
            @recipe = Recipe.find(params[:id])
            if not @recipe
                halt 404
            end
            url = Base64.decode64(params[:url])
            @recipe.pictureList.delete(url)
            @recipe.save!
        rescue => err
            halt 500, err.message
        end
    end
end