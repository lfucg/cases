class PagesController < ApplicationController

  before_filter :set_api_endpoint
  before_filter :set_active_page

  def root;
  end

  def download
    @buckets = Bucket.all.select{ |b| b.events.count > 0 }
  end

  def api_reference
    @buckets = Bucket.all.select{ |b| b.events.count > 0 }
  end

  def error_404
    render status: 404
  end

  private

  def set_api_endpoint
    host = request.host_with_port
    @api_endpoint = host.match(/80|443/) ? host.gsub(/:(80|443)/, '') : host
  end

  def set_active_page
    @home_active = active_class(:root)
    @download_active = active_class(:download)
    @reference_active = active_class(:api_reference)
  end

  def active_class(page)
    action_name == page.to_s ? 'active' : ''
  end

end
