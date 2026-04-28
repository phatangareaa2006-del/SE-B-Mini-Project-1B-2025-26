import { useState, useEffect } from "react";
import {
  LayoutDashboard,
  Briefcase,
  Users,
  TrendingUp,
  Plus,
  Eye,
  Clock,
  CheckCircle,
  XCircle,
  Building2,
  IndianRupee,
  MapPin,
  Calendar,
} from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { useAuth } from "@/contexts/AuthContext";
import { apiClient } from "@/api/client";
import Navbar from "@/components/layout/Navbar";

interface DashboardStats {
  totalJobs: number;
  activeJobs: number;
  totalApplications: number;
  pendingReview: number;
  shortlisted: number;
  hired: number;
}

interface RecentJob {
  id: string;
  title: string;
  created_at: string;
  openings: number | null;
  applications_count: number;
  is_active: boolean;
}

const CompanyDashboard = () => {
  const { user } = useAuth();
  const [company, setCompany] = useState<any>(null);
  const [stats, setStats] = useState<DashboardStats>({
    totalJobs: 0,
    activeJobs: 0,
    totalApplications: 0,
    pendingReview: 0,
    shortlisted: 0,
    hired: 0,
  });
  const [recentJobs, setRecentJobs] = useState<RecentJob[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      fetchDashboardData();
    }
  }, [user]);

  const fetchDashboardData = async () => {
    try {
      // Fetch company
      const company = await apiClient.getMyCompany();
      
      if (company) {
        setCompany(company);

        // Fetch jobs for this company
        const jobs = await apiClient.getCompanyJobs(company.id);

        // Calculate stats
        const totalJobs = jobs?.length || 0;
        const activeJobs = jobs?.filter((j: any) => j.active).length || 0;

        // For now, set basic stats (full stats would require fetching applications)
        setStats({
          totalJobs,
          activeJobs,
          totalApplications: 0,
          pendingReview: 0,
          shortlisted: 0,
          hired: 0,
        });

        // Format recent jobs
        const formattedJobs = (jobs || []).slice(0, 5).map((job: any) => ({
          id: job.id,
          title: job.title,
          created_at: job.created_at,
          openings: job.openings,
          applications_count: 0,
          is_active: job.active,
        }));
        setRecentJobs(formattedJobs);
      }
    } catch (err) {
      console.error("Error fetching dashboard data:", err);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString("en-IN", {
      month: "short",
      day: "numeric",
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mx-auto px-4 py-6">
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <Card key={i}>
                <CardContent className="p-6">
                  <Skeleton className="h-8 w-16 mb-2" />
                  <Skeleton className="h-4 w-24" />
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (!company) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mx-auto px-4 py-12">
          <Card className="max-w-lg mx-auto">
            <CardContent className="p-8 text-center">
              <Building2 className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
              <h2 className="text-2xl font-bold mb-2">Create Your Company Profile</h2>
              <p className="text-muted-foreground mb-6">
                Set up your company profile to start posting jobs and hiring talent.
              </p>
              <Button asChild size="lg">
                <Link to="/company/profile/edit">
                  <Plus className="mr-2 h-5 w-5" />
                  Create Company Profile
                </Link>
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <div className="container mx-auto px-4 py-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
          <div>
            <h1 className="text-2xl font-bold font-display">Company Dashboard</h1>
            <p className="text-muted-foreground">Welcome back, {company.name}</p>
          </div>
          <Button asChild>
            <Link to="/company/post-job">
              <Plus className="mr-2 h-4 w-4" />
              Post New Job
            </Link>
          </Button>
        </div>

        {/* Verification Banner */}
        {company.verification_status === "pending" && (
          <Card className="mb-6 border-warning bg-warning/5">
            <CardContent className="p-4 flex items-center gap-4">
              <Clock className="h-5 w-5 text-warning" />
              <div>
                <p className="font-medium">Verification Pending</p>
                <p className="text-sm text-muted-foreground">
                  Your company profile is being reviewed. You can still post jobs, but they'll be visible after verification.
                </p>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Stats Grid */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4 mb-8">
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Active Jobs</p>
                  <p className="text-3xl font-bold">{stats.activeJobs}</p>
                </div>
                <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center">
                  <Briefcase className="h-6 w-6 text-primary" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Total Applications</p>
                  <p className="text-3xl font-bold">{stats.totalApplications}</p>
                </div>
                <div className="h-12 w-12 rounded-lg bg-info/10 flex items-center justify-center">
                  <Users className="h-6 w-6 text-info" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Pending Review</p>
                  <p className="text-3xl font-bold">{stats.pendingReview}</p>
                </div>
                <div className="h-12 w-12 rounded-lg bg-warning/10 flex items-center justify-center">
                  <Clock className="h-6 w-6 text-warning" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-muted-foreground">Hired</p>
                  <p className="text-3xl font-bold">{stats.hired}</p>
                </div>
                <div className="h-12 w-12 rounded-lg bg-success/10 flex items-center justify-center">
                  <CheckCircle className="h-6 w-6 text-success" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Quick Actions & Recent Jobs */}
        <div className="grid gap-6 lg:grid-cols-3">
          {/* Quick Actions */}
          <Card>
            <CardHeader>
              <CardTitle>Quick Actions</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <Button asChild variant="outline" className="w-full justify-start gap-3">
                <Link to="/company/post-job">
                  <Plus className="h-4 w-4" />
                  Post a New Job
                </Link>
              </Button>
              <Button asChild variant="outline" className="w-full justify-start gap-3">
                <Link to="/company/applicants">
                  <Users className="h-4 w-4" />
                  View All Applicants
                </Link>
              </Button>
              <Button asChild variant="outline" className="w-full justify-start gap-3">
                <Link to="/company/analytics">
                  <TrendingUp className="h-4 w-4" />
                  View Analytics
                </Link>
              </Button>
              <Button asChild variant="outline" className="w-full justify-start gap-3">
                <Link to="/company/profile/edit">
                  <Building2 className="h-4 w-4" />
                  Edit Company Profile
                </Link>
              </Button>
            </CardContent>
          </Card>

          {/* Recent Jobs */}
          <Card className="lg:col-span-2">
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle>Recent Jobs</CardTitle>
              <Button asChild variant="ghost" size="sm">
                <Link to="/company/jobs">View All</Link>
              </Button>
            </CardHeader>
            <CardContent>
              {recentJobs.length === 0 ? (
                <div className="text-center py-8">
                  <Briefcase className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                  <p className="text-muted-foreground mb-4">No jobs posted yet</p>
                  <Button asChild size="sm">
                    <Link to="/company/post-job">Post Your First Job</Link>
                  </Button>
                </div>
              ) : (
                <div className="space-y-4">
                  {recentJobs.map((job) => (
                    <div
                      key={job.id}
                      className="flex items-center justify-between p-3 rounded-lg bg-muted/50"
                    >
                      <div>
                        <Link
                          to={`/company/jobs/${job.id}`}
                          className="font-medium hover:text-primary"
                        >
                          {job.title}
                        </Link>
                        <p className="text-sm text-muted-foreground">
                          Posted {formatDate(job.created_at)} • {job.applications_count}{" "}
                          applications
                        </p>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge variant={job.is_active ? "default" : "secondary"}>
                          {job.is_active ? "Active" : "Closed"}
                        </Badge>
                        <Button asChild variant="ghost" size="icon">
                          <Link to={`/company/jobs/${job.id}/applicants`}>
                            <Eye className="h-4 w-4" />
                          </Link>
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default CompanyDashboard;
