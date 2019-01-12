# frozen_string_literal: true

# loads the frontend
class HomeController < ApplicationController
  layout "front", except: :unsub
  #do we need intercom?
  skip_after_action :intercom_rails_auto_include

  def index
    render inline: '', layout: 'front' # Avoid having an empty view file.
  end

  def unsub
    render layout: "unsub", html: ""
  end
end
