# frozen_string_literal: true

require 'sinatra'
require 'net/http'
require 'json'

class Belafonte < Sinatra::Base
  get '/' do
    locals = {}
    locals.merge!(k8s_pod_info)
    locals.merge!(uuid_from_service)

    erb :index, layout: 'layouts/default'.to_sym, locals: locals
  end

  def k8s_pod_info
    {
      pod_ip: ENV['POD_IP'],
      pod_name: ENV['POD_NAME']
    }
  end

  def uuid_from_service
    uuid_service_prefix = ENV['UUID_SERVICE_NAME'].upcase
    uuid_service_host = ENV["#{uuid_service_prefix}_SERVICE_HOST"]
    uuid_service_port = ENV["#{uuid_service_prefix}_SERVICE_PORT"]
    uuid_service_addr = "http://#{uuid_service_host}:#{uuid_service_port}/uuid"

    parsed_response = JSON.parse(Net::HTTP.get(URI(uuid_service_addr)))

    {
      uuid_service_address: uuid_service_addr,
      uuid: parsed_response['uuid']
    }
  end
end
