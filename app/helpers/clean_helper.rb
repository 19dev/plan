# encoding: utf-8
module CleanHelper
  def clean_error
    session[:error] = nil
  end
  def clean_notice
    session[:notice] = nil
  end
end
