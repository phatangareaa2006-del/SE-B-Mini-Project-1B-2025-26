import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "@/contexts/AuthContext";
import ProtectedRoute from "@/components/auth/ProtectedRoute";

// Public Pages
import Index from "./pages/Index";
import AuthPage from "./pages/AuthPage";
import ForgotPasswordPage from "./pages/ForgotPasswordPage";
import ResetPasswordPage from "./pages/ResetPasswordPage";
import NotFound from "./pages/NotFound";

// Opportunity Pages
import InternshipsPage from "./pages/InternshipsPage";
import MockTestsPage from "./pages/MockTestsPage";
import MentorshipsPage from "./pages/MentorshipsPage";
import SavedPage from "./pages/SavedPage";

// Social Pages
import NetworkPage from "./pages/NetworkPage";
import MessagesPage from "./pages/MessagesPage";
import NotificationsPage from "./pages/NotificationsPage";

// Student Pages
import JobsPage from "./pages/JobsPage";
import JobDetailPage from "./pages/JobDetailPage";
import ApplicationsPage from "./pages/ApplicationsPage";
import ProfilePage from "./pages/ProfilePage";
import SettingsPage from "./pages/SettingsPage";

// Company Pages
import CompanyDashboard from "./pages/company/CompanyDashboard";
import PostJobPage from "./pages/company/PostJobPage";
import CompanyApplicantsPage from "./pages/company/CompanyApplicantsPage";
import CompanyProfileEditPage from "./pages/company/CompanyProfileEditPage";
const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <Routes>
            {/* Public Routes */}
            <Route path="/" element={<Index />} />
            <Route path="/auth" element={<AuthPage />} />
            <Route path="/forgot-password" element={<ForgotPasswordPage />} />
            <Route path="/reset-password" element={<ResetPasswordPage />} />
            
            {/* Opportunity Routes */}
            <Route path="/internships" element={<InternshipsPage />} />
            <Route path="/mock-tests" element={<MockTestsPage />} />
            <Route path="/mentorships" element={<MentorshipsPage />} />
            <Route path="/jobs/:id" element={<JobDetailPage />} />
            <Route
              path="/saved"
              element={<ProtectedRoute><SavedPage /></ProtectedRoute>}
            />
            
            {/* Social Routes */}
            <Route path="/network" element={<ProtectedRoute><NetworkPage /></ProtectedRoute>} />
            <Route path="/messages" element={<ProtectedRoute><MessagesPage /></ProtectedRoute>} />
            <Route path="/notifications" element={<ProtectedRoute><NotificationsPage /></ProtectedRoute>} />

            {/* Student Routes */}
            <Route path="/jobs" element={<JobsPage />} />
            <Route path="/applications" element={<ProtectedRoute allowedRoles={["student"]}><ApplicationsPage /></ProtectedRoute>} />
            <Route path="/profile" element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />
            <Route path="/settings" element={<ProtectedRoute><SettingsPage /></ProtectedRoute>} />

            {/* Company Routes */}
            <Route path="/company/dashboard" element={<ProtectedRoute allowedRoles={["company"]}><CompanyDashboard /></ProtectedRoute>} />

            <Route path="/company/post-job" element={<ProtectedRoute allowedRoles={["company"]}><PostJobPage /></ProtectedRoute>} />
            <Route path="/company/applicants" element={<ProtectedRoute allowedRoles={["company"]}><CompanyApplicantsPage /></ProtectedRoute>} />
            <Route path="/company/jobs/:jobId/applicants" element={<ProtectedRoute allowedRoles={["company"]}><CompanyApplicantsPage /></ProtectedRoute>} />
            <Route path="/company/profile/edit" element={<ProtectedRoute allowedRoles={["company"]}><CompanyProfileEditPage /></ProtectedRoute>} />

            {/* Catch-all */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </BrowserRouter>
      </TooltipProvider>
    </AuthProvider>
  </QueryClientProvider>
);

export default App;
