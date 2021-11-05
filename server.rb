require 'net/http'
require 'nokogiri'
require 'json'
require 'rack'
require 'uri'

class HttpStatus
  OK = 200
  BAD_REQUEST = 400
  NOT_FOUND = 404
end

class ContentType
  FAVICON = { "Content-Type" => "image/vnd.microsoft.icon" }
  TEXT_HTML = { "Content-Type" => "text/html; charset=utf-8" }
  TEXT_PLAIN = { "Content-Type" => "text/plain" }
end

class Awelchy

  USAGE = <<-DOC
  <html>
    <body>
      <h1>Usage:</h1>
      <pre>
        POST /fuzzy-match
        &lt; keywords &gt;
      </pre>
      <h1>Returns:</h1>
      <p>URL to matching image on awelchisms.com</p>
    </body>
  </html>
  DOC

  def self.call(env)
    req = Rack::Request.new(env)
    path = req.env["PATH_INFO"]
    if req.get? && Awelchy.is_base?(path)
      return [HttpStatus::OK, ContentType::TEXT_HTML, [USAGE]]
    end
    if req.get? && Awelchy.is_favicon?(path)
      return [HttpStatus::OK, ContentType::FAVICON, [Awelchy.favicon]]
    end
    if req.post? && Awelchy.is_fuzzy_match?(path)
      body = req.body.read
      puts req.env
      puts body
      return Awelchy.fuzzy_match(JSON.parse(body))
    end
    return [HttpStatus::BAD_REQUEST, ContentType::TEXT_PLAIN, ['Unsupported request.']]
  end

  def self.is_base?(path)
    path == "/"
  end

  def self.is_favicon?(path)
    path == "/favicon.ico"
  end

  def self.is_fuzzy_match?(path)
    path == "/fuzzy-match"
  end

  def self.favicon
    File.open("favicon.ico", "r") do |f|
      return f.read
    end
  end

  def self.fuzzy_match(json)
    terms = json["message"]["text"].split
    awelchisms = Awelchy.awelchisms
    weighed_awelchisms = Awelchy.weigh_urls(terms, awelchisms)
    url = Awelchy.heaviest_url(weighed_awelchisms)
    return [HttpStatus::OK, ContentType::TEXT_PLAIN, [url]] if url
    return [HttpStatus::NOT_FOUND, ContentType::TEXT_PLAIN, []]
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
