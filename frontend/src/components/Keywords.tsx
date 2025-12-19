import { useState, useEffect } from 'react';

interface Keyword {
  id: number;
  keyword: string;
  created_at: string;
}

type KeywordsResponse = Keyword[];

interface KeywordsProps {
  onKeywordsChange?: () => void;
}

export default function Keywords({ onKeywordsChange }: KeywordsProps) {
  const [keywords, setKeywords] = useState<Keyword[]>([]);
  const [newKeyword, setNewKeyword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isAdding, setIsAdding] = useState(false);

  useEffect(() => {
    fetchKeywords();
  }, []);

  const fetchKeywords = async () => {
    try {
      setLoading(true);
      const response = await fetch('http://localhost:3000/keywords', {
        credentials: 'include',
        headers: {
          'Accept': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to fetch keywords');
      }

      const data: KeywordsResponse = await response.json();
      setKeywords(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load keywords');
    } finally {
      setLoading(false);
    }
  };

  const handleAddKeyword = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newKeyword.trim()) return;

    try {
      setIsAdding(true);
      setError(null);
      const response = await fetch('http://localhost:3000/keywords', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify({
          keyword: {
            keyword: newKeyword.trim(),
          },
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.status?.message || data.errors?.join(', ') || 'Failed to add keyword');
      }

      setNewKeyword('');
      await fetchKeywords(); // Refresh the list
      // Notify parent to refresh articles
      onKeywordsChange?.();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add keyword');
    } finally {
      setIsAdding(false);
    }
  };

  const handleDeleteKeyword = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this keyword?')) {
      return;
    }

    try {
      setError(null);
      const response = await fetch(`http://localhost:3000/keywords/${id}`, {
        method: 'DELETE',
        headers: {
          'Accept': 'application/json',
        },
        credentials: 'include',
      });

      if (!response.ok) {
        const data = await response.json();
            throw new Error(data.status?.message || 'Failed to delete keyword');
          }

          await fetchKeywords(); // Refresh the list
          // Notify parent to refresh articles
          onKeywordsChange?.();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete keyword');
    }
  };

  return (
    <div className="bg-white shadow rounded-lg p-6 mt-6">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Manage Keywords</h3>

      {error && (
        <div className="mb-4 rounded-md bg-red-50 p-4">
          <div className="text-sm text-red-800">{error}</div>
        </div>
      )}

      <form onSubmit={handleAddKeyword} className="mb-4">
        <div className="flex gap-2">
          <input
            type="text"
            value={newKeyword}
            onChange={(e) => setNewKeyword(e.target.value)}
            placeholder="Enter a keyword"
            className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            disabled={isAdding}
          />
          <button
            type="submit"
            disabled={isAdding || !newKeyword.trim()}
            className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isAdding ? 'Adding...' : 'Add'}
          </button>
        </div>
      </form>

      {loading ? (
        <div className="text-gray-500">Loading keywords...</div>
      ) : keywords.length === 0 ? (
        <div className="text-gray-500 text-sm">No keywords yet. Add one above to get started.</div>
      ) : (
        <div className="space-y-2">
          <div className="text-sm text-gray-600 mb-2">Your keywords:</div>
          <div className="flex flex-wrap gap-2">
            {keywords.map((keyword) => (
              <div
                key={keyword.id}
                className="inline-flex items-center gap-2 px-3 py-1 bg-indigo-100 text-indigo-800 rounded-full text-sm"
              >
                <span>{keyword.keyword}</span>
                <button
                  onClick={() => handleDeleteKeyword(keyword.id)}
                  className="text-indigo-600 hover:text-indigo-800 focus:outline-none"
                  title="Delete keyword"
                >
                  ×
                </button>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

