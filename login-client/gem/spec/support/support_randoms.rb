module SupportRandoms
  def random_date
    random_past_date + rand(1000).days
  end

  def random_past_date(range: 500)
    Date.current.days_ago(rand(range))
  end

  def random_time
    rand(DateTime.current.years_ago(5)..DateTime.current.years_since(5))
  end

  def random_future_time
    DateTime.current.days_since(rand(1..1000))
  end

  def random_past_time
    DateTime.current.days_ago(rand(1..1000))
  end

  def random_duration
    rand(1..1000).days
  end

  def random_hash(symbolic_keys: true, key_count: 3)
    result = {}
    key_count.times do
      result[Faker::Lorem.word] = random_hex_string
    end
    symbolic_keys == true ? result.symbolize_keys : result
  end

  def frand(x)
    Random.rand(x * 1.0).round(2)
  end

  def random_americanstate
    abbreviation = us_states.keys.sample
    Americanstate.where(abbreviation: abbreviation.to_s).first ||
      FactoryBot.create(:americanstate, abbreviation: abbreviation.to_s, name: us_states[abbreviation])
  end

  def random_uri
    fqdn = [Faker::Lorem.word, SecureRandom.hex(3), 'localdomain'].join('.')
    URI.parse(Faker::Internet.url(host: fqdn))
  end

  def random_hex_string
    SecureRandom.hex
  end

  def lorem_sentence
    Faker::Lorem.sentence
  end

  def lorem_word
    Faker::Lorem.word
  end

end
