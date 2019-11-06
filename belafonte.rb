# frozen_string_literal: true

require 'sinatra'
require 'net/http'
require 'json'
require 'logger'

class Belafonte < Sinatra::Base
  get '/' do
    locals = {}
    locals.merge!(k8s_pod_info)
    locals.merge!(uuid_info)

    logger.info("Request received. Responding with #{locals}")
    erb :index, layout: 'layouts/default'.to_sym, locals: locals
  end

  def k8s_pod_info
    {
      pod_ip: ENV['POD_IP'] || 'UNAVAILABLE',
      pod_name: ENV['POD_NAME'] || 'UNAVAILABLE'
    }
  end

  def uuid_info
    addr = uuid_service_addr
    return {uuid_service_address: 'NOT CONFIGURED', uuid: 'UNAVAILABLE'} unless addr

    {
      uuid_service_address: addr,
      uuid: uuid_from_service(addr)
    }
  end

  def uuid_service_addr
    uuid_service_prefix = ENV['UUID_SERVICE_NAME']&.upcase
    uuid_service_host = ENV["#{uuid_service_prefix}_SERVICE_HOST"]
    uuid_service_port = ENV["#{uuid_service_prefix}_SERVICE_PORT"]

    return nil unless uuid_service_host && uuid_service_port

    "http://#{uuid_service_host}:#{uuid_service_port}/uuid"
  end

  def uuid_from_service(addr)
    logger.info("Fetching UUID from #{addr}")
    parsed_response = JSON.parse(Net::HTTP.get(URI(addr)))
    parsed_response['uuid']
  rescue => e
    logger.error("Error fetching UUID: #{e}")
    'UNAVAILABLE'
  end

  def logger
    @_logger ||= Logger.new(STDOUT)
  end
end
