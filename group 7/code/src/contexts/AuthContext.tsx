import React, { createContext, useContext, useEffect, useState } from "react";
import { apiClient } from "@/api/client";

export type AppRole = "student" | "company" | "college_admin" | "super_admin";

interface User {
  id: string;
  email: string;
  fullName?: string;
  role: AppRole;
}

interface AuthContextType {
  user: User | null;
  role: AppRole | null;
  loading: boolean;
  signUp: (
    email: string,
    password: string,
    fullName: string,
    role: AppRole,
    collegeId?: string
  ) => Promise<{ error: Error | null }>;
  signIn: (email: string, password: string) => Promise<{ error: Error | null }>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<{ error: Error | null }>;
  updatePassword: (password: string) => Promise<{ error: Error | null }>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<AppRole | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is already logged in
    const token = localStorage.getItem("auth_token");
    if (token) {
      // Decode token to get user info (basic JWT decode)
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        setUser({
          id: payload.userId,
          email: payload.email,
          role: payload.role,
        });
        setRole(payload.role);
      } catch (error) {
        console.error("Invalid token", error);
        localStorage.removeItem("auth_token");
      }
    }
    setLoading(false);
  }, []);

  const signUp = async (
    email: string,
    password: string,
    fullName: string,
    role: AppRole,
    collegeId?: string
  ) => {
    try {
      const response: any = await apiClient.signup(
        email,
        password,
        fullName,
        role,
        collegeId
      );

      apiClient.setToken(response.token);

      setUser({
        id: response.user.id,
        email: response.user.email,
        fullName: response.user.fullName,
        role: response.user.role,
      });

      setRole(response.user.role);

      return { error: null };
    } catch (error) {
      return { error: error as Error };
    }
  };

  const signIn = async (email: string, password: string) => {
    try {
      const response: any = await apiClient.signin(email, password);

      apiClient.setToken(response.token);

      setUser({
        id: response.user.id,
        email: response.user.email,
        role: response.user.role,
      });

      setRole(response.user.role);

      return { error: null };
    } catch (error) {
      return { error: error as Error };
    }
  };

  const signOut = async () => {
    apiClient.clearToken();
    setUser(null);
    setRole(null);
  };

  const resetPassword = async (email: string) => {
    try {
      await apiClient.resetPassword(email);
      return { error: null };
    } catch (error) {
      return { error: error as Error };
    }
  };

  const updatePassword = async (password: string) => {
    try {
      await apiClient.updatePassword(password);
      return { error: null };
    } catch (error) {
      return { error: error as Error };
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        role,
        loading,
        signUp,
        signIn,
        signOut,
        resetPassword,
        updatePassword,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
};
