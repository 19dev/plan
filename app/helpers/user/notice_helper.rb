# encoding: utf-8
module User
  module NoticeHelper
    def noticeadd
      params.select! { |k, v| Notice.columns.collect {|c| c.name}.include?(k) }
      if flash[:error] = control({params[:content] => "İçerik",})
        return redirect_to '/user/noticenew'
      end

      notice = Notice.new params
      notice.save
      session[:notice_id] = notice.id

      flash[:success] = "duyuru başarıyla eklendi"
      redirect_to '/user/noticeshow'
    end
    def noticeshow
      session[:notice_id] = params[:notice_id] if params[:notice_id] # uniq veriyi oturuma gömelim
      unless @notice = Notice.find(session[:notice_id])
        flash[:error] = "Böyle bir duyuru bulunmamaktadır"
        redirect_to '/user/noticereview'
      end
    end
    def noticeedit
      session[:notice_id] = params[:notice_id] if params[:notice_id] # uniq veriyi oturuma gömelim
      @notice = Notice.find session[:notice_id]
    end
    def noticedel
      session[:notice_id] = params[:notice_id] if params[:notice_id] # uniq veriyi oturuma gömelim
      flash[:success] = "duyuru başarıyla silindi"
      Notice.delete session[:notice_id]
      session[:notice_id] = nil # dersin oturumunu öldürelim
      redirect_to '/user/noticereview'
    end
    def noticeupdate
      params.select! { |k, v| Notice.columns.collect {|c| c.name}.include?(k) }

      if flash[:error] = control({params[:content] => "İçerik",})
        return redirect_to '/user/noticeshow'
      end

      Notice.update(session[:notice_id], params)
      flash[:success] = "duyuru başarıyla güncellendi"

      redirect_to '/user/noticeshow'
    end
  end
end
