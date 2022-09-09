require 'sinatra'
require 'sinatra/json'
require 'json'
require 'paypal-checkout-sdk'
require 'dotenv'

set :json_content_type, :json

# load the environment
Dotenv.load(File.join(File.dirname(__FILE__), '../../payments/.env'))

# Creating Access Token for Sandbox
client_id = ENV['PAYPAL_STANDALONE_TEST_CLIENTID'] || raise("cannot find client_id")
client_secret = ENV['PAYPAL_STANDALONE_TEST_SECRET'] || raise("cannot find secret id")

# Creating an environment
environment = PayPal::SandboxEnvironment.new(client_id, client_secret)
client = PayPal::PayPalHttpClient.new(environment)

get '/' do
    File.read(File.join(File.dirname(__FILE__),'test.html')).gsub("QTOgcCcAPDc7V_5CkqaT8OLzc4YAA_380J_ChxjAXVo_amDCvMvWDDH_lAIOYBQracNyLKZSp-NujJm",client_id)
end

post '/order' do
    request = PayPalCheckoutSdk::Orders::OrdersCreateRequest::new
    request.request_body({
                        intent: "CAPTURE",
                        purchase_units: [
                            {
                                amount: {
                                    currency_code: "USD",
                                    value: "2.#{rand(10..99)}"
                                }
                            }
                        ]
                      })
    order = nil
    begin
        response = client.execute(request)

        order = response.result
        puts order
    rescue PayPalHttp::HttpError => ioe
        # Something went wrong server-side
        puts ioe.status_code
        puts ioe.headers["debug_id"]
        raise ioe
    end
    json :id => order.id
end

post '/order/:id/capture' do |id|
    puts "Got Id #{id}"
    json :response => "ok"
end
