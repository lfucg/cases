# Internal job enqueue api
class JobsController < ApplicationController
  protect_from_forgery except: :enqueue
  http_basic_authenticate_with name: Rails.application.config.jobs_api_user,
                               password: Rails.application.config.jobs_api_pass

  def enqueue
    job = params[:job]
    args = params[:arg]
    worker_name = "#{job}_worker".camelize
    worker = worker_name.constantize rescue nil
    if worker
      worker.perform_async(*args)
      head :ok
    else
      head :bad_request
    end
  end

end
