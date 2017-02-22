require 'yelp'
require 'rubygems'
require 'twilio-ruby'

#yelp api setup

Yelp.client.configure do |config|
    config.consumer_key = ENV['YELP_CONSUMER_KEY']
    config.consumer_secret = ENV['YELP_CONSUMER_SECRET']
    config.token = ENV['YELP_TOKEN']
    config.token_secret = ENV['YELP_TOKEN_SECRET']
end

#business ID list
list = %w(
cheers-cut-flushing-3
royal-queen-flushing
lilac-service-astoria
)

def send_message(message)
    #twilio setup
    account_sid = ENV['TWILIO_SID']
    auth_token =   ENV['TWILIO_TOKEN']
    phone_client = Twilio::REST::Client.new account_sid, auth_token

    sender = "+15162102226" # Your Twilio number
    receiver = {
        "+16469156636" => "Clare"
    }
    receiver.each do |key, value|
        phone_client.account.messages.create(
            :from => sender,
            :to => key,
            :body => "Hey #{value}, clients #{message} have new reviews"
        )
        puts "Sent message to #{value}"
    end
end

def get_comments(list)
    hash = Hash.new
    list.each do |value|
        name = Yelp.client.business(value).business.name
        hash[name] = Yelp.client.business(value).business.review_count
    end
    return hash
end

#initial comments

initial_comments = get_comments(list)
p initial_comments
sleep 10

while true do
    message = []
    @send = false
    updated_comments = get_comments(list)
    p updated_comments
    updated_comments.each do |key,value|
        if updated_comments[key] != initial_comments[key]
            initial_comments[key] = updated_comments[key]
            message << key
            @send = true
        end
    end
    if @send == true
        p 'Sending msg'
        message=message*","
        send_message(message)
        #Set checking frequency here, default is avoiding weekend checking
        if Time.now.strftime("%A") == "Friday"
            sleep 72*3600
        else
            sleep 24*3600
        end
    else
        p "no update"
    end
end
