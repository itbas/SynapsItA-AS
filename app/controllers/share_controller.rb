class ShareController < ApplicationController
  before_filter :authenticate_user!
	before_action :set_topic, only: [:save]
  respond_to :json

  def list
  	respond_with current_user.share.all.to_json(:include => [:posts, :owner])
  end

  def users
  	respond_with User.all
  end

  def curr_user
  	respond_with current_user
  end

  def save
  	User.all.each do |user|
      user.share.delete(@topic)
      user.save
    end

    unless params[:shared_with_ids].nil?
      params[:shared_with_ids].each do |shared_with_id|
        user = User.find(shared_with_id)

        @topic.shared_with.push(user)
        user.share.push(@topic)

        msg = "#{current_user.email} shared '#{@topic.name}' with you!"
        user.inbox.push(Message.new(type: "_share", content: msg ))
      end
    end

    respond_with @topic
  end

  private
    def set_topic
      @topic = Topic.find(params[:id])
    end
end
