# encoding: utf-8
module CleanHelper
  def clean_error
    session[:error] = nil
  end
  def clean_notice
    session[:success] = nil
  end
end
