desc "This task is called by the Heroku cron add-on; requests page to keep server awake"
task :call_page => :environment do
   uri = URI.parse('http://spinecenter-tv.herokuapp.com')
   Net::HTTP.get(uri)
 end