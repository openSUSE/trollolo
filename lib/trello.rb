#  Copyright (c) 2013-2014 SUSE LLC
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 3 of the GNU General Public License as
#  published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.
#
#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

class Trello
  class ApiError < StandardError; end

  attr_accessor :board_id

  attr_reader   :developer_public_key, :member_token

  def initialize settings
    @developer_public_key = settings.fetch(:developer_public_key)
    @member_token         = settings.fetch(:member_token)
    @board_id             = settings.fetch(:board_id)
  end

  def lists
    get "lists"
  end

  def cards
    get "cards"
  end

  def checklists
    get "checklists"
  end

  private

  def resource_url resource
    "/1/boards/#{board_id}/#{resource}?key=#{developer_public_key}&token=#{member_token}"
  end

  # FIXME: we should handle time-outs gracefully.

  def get resource
    resp = http_client.get resource_url(resource)
    unless resp.code == "200"
      raise ApiError.new("Error occured while connecting to the trello API.")
    end
    JSON.parse(resp.body)
  rescue JSON::ParserError => e
    raise ApiError.new(e)
  end

  def http_client
    http = Net::HTTP.new "trello.com", 443
    http.use_ssl = true
    http
  end
end
