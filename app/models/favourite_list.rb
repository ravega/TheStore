# The current visitor's list of favourite articles.
#
# There are no user accounts in the store, so favourites are kept per visitor
# in the Rails session as an ordered list of article ids.
class FavouriteList
  SESSION_KEY = :favourite_article_ids
  # The session lives in a 4 KB cookie that also holds the CSRF token and the
  # flash; 50 ids of up to 10 digits stay comfortably inside that limit.
  MAX_SIZE = 50
  ID_FORMAT = /\A\d{1,10}\z/

  def initialize(session)
    @session = session
  end

  def ids
    Array(@session[SESSION_KEY]).map(&:to_i)
  end

  # Adds the given article ids (existing articles only, duplicates ignored),
  # up to MAX_SIZE. Returns how many articles were newly added.
  def add(article_ids)
    current = ids
    found = Article.where(id: sanitize(article_ids)).pluck(:id)
    combined = (current | found).first(MAX_SIZE)
    store(combined)
    combined.size - current.size
  end

  # Removes an article id. Returns true if it was in the list.
  def remove(article_id)
    id = self.class.parse_id(article_id)
    current = ids
    return false unless id && current.include?(id)
    store(current - [id])
    true
  end

  def include?(article)
    ids.include?(article.id)
  end

  def full?
    ids.size >= MAX_SIZE
  end

  # Favourite articles that still exist, in the order they were added.
  def articles
    current = ids
    return [] if current.empty?
    Article.where(id: current).index_by(&:id).values_at(*current).compact
  end

  def count
    current = ids
    current.empty? ? 0 : Article.where(id: current).count
  end

  # Returns the integer id for a well-formed id string, otherwise nil.
  def self.parse_id(value)
    value.is_a?(String) && value =~ ID_FORMAT ? value.to_i : nil
  end

  private

    def sanitize(values)
      Array(values).map { |value| self.class.parse_id(value) }.compact.uniq
    end

    def store(new_ids)
      @session[SESSION_KEY] = new_ids
    end
end
