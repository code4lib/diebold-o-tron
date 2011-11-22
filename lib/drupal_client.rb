require 'net/http'
class DrupalClient
  def initialize(host, username, password)
    @host = host   
    @username = username
    @password = password
    @uri = URI.parse(@host)  
  end
  
  def login
    res = Net::HTTP.post_form(@uri,{'edit[name]'=>@username,
      'edit[pass]'=>@password,'edit[form_id]'=>'user_login_block'})
    if res.code == "302"
      return res.header["location"].split("/").last.to_i
    end
    return 0
  end
  
end
