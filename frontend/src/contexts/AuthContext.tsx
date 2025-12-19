import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface User {
  email: string;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  signUp: (email: string, password: string, passwordConfirmation: string) => Promise<void>;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    // Check if user is already logged in (check for session)
    checkAuthStatus();
  }, []);

  const checkAuthStatus = async () => {
    try {
      // Try to fetch a protected resource to check if user is authenticated
      const response = await fetch('http://localhost:3000/', {
        credentials: 'include',
      });
      if (response.ok) {
        // User is authenticated, but we don't have user info from this endpoint
        // For now, we'll check by trying to access a user-specific endpoint
        // Or we can store user info in localStorage after login
        const storedUser = localStorage.getItem('user');
        if (storedUser) {
          setUser(JSON.parse(storedUser));
        }
      }
    } catch (error) {
      console.error('Auth check failed:', error);
    } finally {
      setLoading(false);
    }
  };

  const signUp = async (email: string, password: string, passwordConfirmation: string) => {
    let response: Response;
    try {
      response = await fetch('http://localhost:3000/users', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        credentials: 'include',
        mode: 'cors',
        body: JSON.stringify({
          user: {
            email,
            password,
            password_confirmation: passwordConfirmation,
          },
        }),
      });
    } catch (error) {
      console.error('Sign up fetch error:', error);
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      
      // Check if it's a network error
      if (errorMessage.includes('Failed to fetch') || errorMessage.includes('NetworkError')) {
        throw new Error('Cannot connect to backend server. Please ensure:\n1. Backend is running on http://localhost:3000\n2. No firewall is blocking the connection\n3. Try restarting the backend server');
      }
      
      throw new Error(`Failed to connect to server: ${errorMessage}. Please make sure the backend is running on http://localhost:3000`);
    }

    let data;
    try {
      data = await response.json();
    } catch (error) {
      throw new Error('Invalid response from server');
    }

    if (!response.ok) {
      throw new Error(data.status?.message || data.error || data.errors?.join(', ') || 'Sign up failed');
    }

    const userData = { email: data.data?.email || email };
    setUser(userData);
    localStorage.setItem('user', JSON.stringify(userData));
  };

  const signIn = async (email: string, password: string) => {
    let response: Response;
    try {
      response = await fetch('http://localhost:3000/users/sign_in', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        credentials: 'include',
        mode: 'cors',
        body: JSON.stringify({
          user: {
            email,
            password,
          },
        }),
      });
    } catch (error) {
      console.error('Sign in fetch error:', error);
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      
      // Check if it's a network error
      if (errorMessage.includes('Failed to fetch') || errorMessage.includes('NetworkError')) {
        throw new Error('Cannot connect to backend server. Please ensure:\n1. Backend is running on http://localhost:3000\n2. No firewall is blocking the connection\n3. Try restarting the backend server');
      }
      
      throw new Error(`Failed to connect to server: ${errorMessage}. Please make sure the backend is running on http://localhost:3000`);
    }

    let data;
    try {
      data = await response.json();
    } catch (error) {
      throw new Error('Invalid response from server');
    }

    if (!response.ok) {
      throw new Error(data.status?.message || data.error || data.errors?.join(', ') || 'Invalid email or password');
    }

    const userData = { email: data.data?.email || email };
    setUser(userData);
    localStorage.setItem('user', JSON.stringify(userData));
  };

  const signOut = async () => {
    try {
      await fetch('http://localhost:3000/users/sign_out', {
        method: 'DELETE',
        credentials: 'include',
      });
    } catch (error) {
      console.error('Sign out error:', error);
    } finally {
      setUser(null);
      localStorage.removeItem('user');
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        signUp,
        signIn,
        signOut,
        loading,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

