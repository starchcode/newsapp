import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

interface Article {
  title: string;
  description: string;
  url: string;
  urlToImage: string | null;
  publishedAt: string;
  author: string | null;
  source: {
    name: string;
  };
}

interface ArticlesListProps {
  refreshTrigger?: number;
}

export default function ArticlesList({ refreshTrigger }: ArticlesListProps) {
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    fetchArticles();
  }, [refreshTrigger]);

  const fetchArticles = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch('http://localhost:3000/articles', {
        credentials: 'include',
        headers: {
          'Accept': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to fetch articles');
      }

      const data: Article[] = await response.json();
      setArticles(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load articles');
    } finally {
      setLoading(false);
    }
  };

  const handleArticleClick = (article: Article, index: number) => {
    navigate(`/articles/${index}`, { state: { article } });
  };

  if (loading) {
    return (
      <div className="bg-white shadow rounded-lg p-6 mt-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">News Articles</h3>
        <div className="text-gray-500">Loading articles...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-white shadow rounded-lg p-6 mt-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">News Articles</h3>
        <div className="text-red-600 text-sm">{error}</div>
      </div>
    );
  }

  if (articles.length === 0) {
    return (
      <div className="bg-white shadow rounded-lg p-6 mt-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">News Articles</h3>
        <div className="text-gray-500 text-sm">
          No articles found. Add some keywords to see relevant news articles.
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white shadow rounded-lg p-6 mt-6">
      <h3 className="text-lg font-semibold text-gray-900 mb-6">News Articles ({articles.length})</h3>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {articles.map((article, index) => (
          <div
            key={index}
            onClick={() => handleArticleClick(article, index)}
            className="border border-gray-200 rounded-lg overflow-hidden hover:shadow-lg transition-shadow cursor-pointer bg-white"
          >
            {article.urlToImage && (
              <img
                src={article.urlToImage}
                alt={article.title}
                className="w-full h-48 object-cover"
                onError={(e) => {
                  (e.target as HTMLImageElement).style.display = 'none';
                }}
              />
            )}
            <div className="p-4">
              <h4 className="text-lg font-semibold text-gray-900 mb-3 hover:text-indigo-600 line-clamp-2">
                {article.title}
              </h4>
              {article.author && (
                <p className="text-sm text-gray-600 mb-2">
                  By <span className="font-medium">{article.author}</span>
                </p>
              )}
              {article.source?.name && (
                <p className="text-xs text-gray-500">
                  {article.source.name}
                </p>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

