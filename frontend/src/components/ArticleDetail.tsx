import { useLocation, useNavigate } from 'react-router-dom';

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

export default function ArticleDetail() {
  const location = useLocation();
  const navigate = useNavigate();
  const article = (location.state as { article?: Article })?.article;

  const formatDate = (dateString: string) => {
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      });
    } catch {
      return dateString;
    }
  };

  if (!article) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-4xl mx-auto py-12 px-4">
          <div className="bg-white shadow rounded-lg p-8 text-center">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Article Not Found</h2>
            <p className="text-gray-600 mb-6">The article you are looking for does not exist.</p>
            <button
              onClick={() => navigate('/welcome')}
              className="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-2 rounded-md"
            >
              Back to Articles
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto py-12 px-4">
        <button
          onClick={() => navigate('/welcome')}
          className="mb-6 text-indigo-600 hover:text-indigo-800 font-medium"
        >
          ← Back to Articles
        </button>

        <article className="bg-white shadow rounded-lg overflow-hidden">
          {article.urlToImage && (
            <img
              src={article.urlToImage}
              alt={article.title}
              className="w-full h-64 object-cover"
              onError={(e) => {
                (e.target as HTMLImageElement).style.display = 'none';
              }}
            />
          )}
          <div className="p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-4">{article.title}</h1>
            
            <div className="flex items-center gap-4 text-sm text-gray-500 mb-6 pb-6 border-b">
              {article.source?.name && (
                <span className="font-medium">{article.source.name}</span>
              )}
              {article.author && (
                <span>By {article.author}</span>
              )}
              {article.publishedAt && (
                <span>{formatDate(article.publishedAt)}</span>
              )}
            </div>

            {article.description && (
              <div className="prose max-w-none mb-8">
                <p className="text-gray-700 text-lg leading-relaxed whitespace-pre-line">
                  {article.description}
                </p>
              </div>
            )}

            {article.url && (
              <div className="pt-6 border-t">
                <a
                  href={article.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center px-6 py-3 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 font-medium"
                >
                  Read Full Article →
                </a>
              </div>
            )}
          </div>
        </article>
      </div>
    </div>
  );
}

