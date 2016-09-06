class Api::V1::BaseController < ApplicationController

  respond_to :json

  protected

  def build_response(data = {}, success = true, code = 0, message = 'OK', status = 200)

    _ret = {
        timestamp: Time.now.getutc.to_i,
        success: success,
        code: code,
        message: message
    }

    _ret.merge!(data)

    render status: status, json: _ret

  end

end