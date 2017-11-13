require 'facter'
require 'ipaddr'
require 'open-uri'

content = ''
# Connect to Satellite to get IP address. Try DNS name first, they try site1 server, then try site2 server
begin
  open("http://sat6.example.com/pub/ip.php") { |f| content = f.read }
rescue
  begin
    open("http://192.168.1.0/pub/ip.php") { |f| content = f.read }
  rescue
    begin
      open("http://192.168.2.0/pub/ip.php") { |f| content = f.read }
    rescue
      # If we cannot get anything from either server we give up
      Facter.add("site") do
            setcode do
                  'Failed to get IP from server'
                  end
            end
    end
  end
end

# Use IP we got above to tell if we are at site1 of site2.
if content != ''
  ip = IPAddr.new(content)
  # Define site1 & site2 subnets
  site1 = [IPAddr.new("192.168.3.0/26"), IPAddr.new("192.168.1.0/25"), IPAddr.new("10.0.0.0/16")]
  site2 = [IPAddr.new("192.168.4.0/30"), IPAddr.new("192.168.2.0/24")]

  Facter.add("site") do
          setcode do
                  # Compare IP received from Satellite to the HDC & DRS arrays
                  if defined? ip
                    if site1.any? { |i| i.include?(ip) }
                      "site1"
                    elsif site2.any? { |i| i.include?(ip) }
                      "site2"
                    else
                      "Failed to match #{content} to a site, check site1 & site2 arrays."
                    end
                  else
                    "ip not defined! Something happened getting response from server"
                  end
          end
  end
end
