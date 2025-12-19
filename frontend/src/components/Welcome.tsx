import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import Keywords from './Keywords';
import ArticlesList from './ArticlesList';

interface ApiResponse {
  message: string;
}

export default function Welcome() {
  const [data, setData] = useState<ApiResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshArticles, setRefreshArticles] = useState(0);
  const { user, signOut } = useAuth();
  const navigate = useNavigate();

  const handleKeywordsChange = () => {
    // Trigger articles refresh by updating the refresh counter
    setRefreshArticles(prev => prev + 1);
  };

  useEffect(() => {
    async function fetchData() {
      try {
        const response = await fetch('http://localhost:3000/', {
          credentials: 'include',
        });
        if (!response.ok) {
          throw new Error('Failed to fetch welcome message');
        }
        const jsonData: ApiResponse = await response.json();
        setData(jsonData);
        setLoading(false);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  const handleSignOut = async () => {
    await signOut();
    navigate('/login');
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-lg">Loading...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-red-600">Error: {error}</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-xl font-semibold">Welcome</h1>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-gray-700">Signed in as: {user?.email}</span>
              <button
                onClick={handleSignOut}
                className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md text-sm font-medium"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </nav>
      <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="border-4 border-dashed border-gray-200 rounded-lg p-8 text-center mb-6">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">{data?.message}</h2>
            <p className="text-gray-600">You are successfully authenticated!</p>
          </div>
          <Keywords onKeywordsChange={handleKeywordsChange} />
          <ArticlesList refreshTrigger={refreshArticles} />
        </div>
      </div>
    </div>
  );
}

