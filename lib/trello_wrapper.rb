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
require 'trello'

class TrelloWrapper
  def initialize(settings)
    @settings = settings
    @boards = {}
    init_trello
  end

  def client
    Trello::Client.new(
      developer_public_key: @settings.developer_public_key,
      member_token: @settings.member_token
    )
  end

  def boards(board_id)
    return @boards[board_id] if @boards.key?(board_id)
    @boards[board_id] = ScrumBoard.new(retrieve_board_data(board_id), @settings)
  end

  def retrieve_board_data(board_id)
    JSON.parse(client.get("/boards/#{board_id}?lists=open&cards=open&card_checklists=all"))
  end

  def backup(board_id)
    client.get("/boards/#{board_id}?lists=open&cards=open&card_checklists=all")
  end

  def organization(org_id)
    Trello::Organization.find(org_id)
  end

  def add_attachment(card_id, filename)
    card = Trello::Card.find(card_id)
    card.add_attachment(File.open(filename, "rb"))
  end

  def make_cover(card_id, image_name)
    attachment_id = attachment_id_by_name(card_id, image_name)
    raise("Error: The attachment with the name '#{image_name}' was not found") if !attachment_id
    client.put("/cards/#{card_id}/idAttachmentCover?value=#{attachment_id}")
  end

  def attachment_id_by_name(card_id, image_name)
    json = JSON.parse(client.get("/cards/#{card_id}/attachments?fields=name"))
    attachment = json.find{ |e| e["name"] == image_name }
    if attachment
      attachment["id"]
    else
      nil
    end
  end

  def get_description(card_id)
    card = Trello::Card.find(card_id)
    card.desc
  end

  def get_member_boards(member_id)
    JSON.parse(client.get("/members/#{member_id}/boards"))
  end

  def set_description(card_id, description)
    client.put("/cards/#{card_id}/desc?value=#{description}")
  end

  def set_name(card_id, name)
    client.put("/cards/#{card_id}/name?value=#{name}")
  end

  def get_cards_from_list(list_id)
    JSON.parse(client.get("/lists/#{list_id}/cards"))
  end

  def find_list(board_id, list_name)
    boards(board_id).columns.find { |list| list.name == list_name }
  end

  private

  def init_trello
    Trello.configure do |config|
      config.developer_public_key = @settings.developer_public_key
      config.member_token         = @settings.member_token
    end
  end

end
