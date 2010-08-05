class FacebooksController < ApplicationController

  # handle Facebook Auth Cookie generated by JavaScript SDK
  def show
    auth = Facebook.auth.from_cookie(cookies)
    authenticate Facebook.identify(auth.user)
    redirect_to dashboard_url
  end

  # handle Normal OAuth flow: start
  def new
    redirect_to Facebook.auth.client.web_server.authorize_url(
      :redirect_uri => callback_facebook_url,
      :scope => Facebook.config[:perms]
    )
  end

  # handle Normal OAuth flow: callback
  def create
    access_token = Facebook.auth.client.web_server.get_access_token(
      params[:code],
      :redirect_uri => callback_facebook_url
    )
    user = FbGraph::User.me(access_token).fetch

    # TODO: fix this issue in fb_graph gem
    user.access_token = access_token

    authenticate Facebook.identify(user)
    redirect_to dashboard_url
  end

end
