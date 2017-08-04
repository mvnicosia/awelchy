require 'net/http'
require 'nokogiri'
require 'rack'
require 'rack/server'

OK = 200
NOT_FOUND = 404
BAD_REQUEST = 400
TEXT_PLAIN = { "Content-Type" => "text/plain" }

class Awelchy

  def self.call(env)
    req = Rack::Request.new env
    path_info = req.env["PATH_INFO"]
    if req.post?
      return Awelchy.fuzzy_match(req) if Awelchy.is_fuzzy_match?(path_info)
    end
    return [BAD_REQUEST, TEXT_PLAIN, ['Unsupported request.']]
  end

  def self.is_fuzzy_match?(path_info)
    path_info == "/fuzzy-match"
  end

  def self.fuzzy_match(req)
    body = req.body.read
    terms = body.split
    awelchisms = Awelchy.awelchisms
    weighed_awelchisms = Awelchy.weigh_urls(terms, awelchisms)
    url = Awelchy.heaviest_url(weighed_awelchisms)
    return [OK, TEXT_PLAIN, [url]] if url
    return [NOT_FOUND, TEXT_PLAIN, []]
  end

  def self.weigh_urls(terms, urls)
    urls.map do |url| 
      weight = 0
      terms.each do |term|
        weight += 1 if url.include?(term)
      end
      { weight: weight, url: url }
    end
  end

  def self.heaviest_url(weighed_urls)
    heaviest = weighed_urls.sort_by { |k| k[:weight] }.last
    heaviest[:weight] > 0 ? heaviest[:url] : nil
  end

  def self.awelchisms
    doc = Nokogiri::HTML(Net::HTTP.get('www.awelchisms.com', '/'))
    doc.search('img').map { |img| img.attributes['src'].value }
  end
end

Rack::Server.start :app => Awelchy
