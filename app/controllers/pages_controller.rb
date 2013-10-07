class PagesController < ApplicationController
  def root
  end

  def error_404
    render status: 404
  end
end
