import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import {
  Briefcase,
  Clock,
  CheckCircle,
  XCircle,
  Eye,
  MessageSquare,
  Calendar,
  ChevronRight,
  Filter,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useAuth } from "@/contexts/AuthContext";
import Navbar from "@/components/layout/Navbar";
import { cn } from "@/lib/utils";

interface Application {
  id: string;
  status: string;
  created_at: string;
  updated_at: string;
  skill_match_percentage: number | null;
  company_feedback: string | null;
  interview_date: string | null;
  job: {
    id: string;
    title: string;
    company: {
      id: string;
      name: string;
      logo_url: string | null;
    } | null;
  } | null;
}

const statusConfig: Record<string, { icon: any; color: string; label: string }> = {
  applied: { icon: Clock, color: "status-applied", label: "Applied" },
  under_review: { icon: Eye, color: "status-under_review", label: "Under Review" },
  shortlisted: { icon: CheckCircle, color: "status-shortlisted", label: "Shortlisted" },
  interview: { icon: Calendar, color: "status-interview", label: "Interview" },
  offer: { icon: CheckCircle, color: "status-offer", label: "Offer" },
  hired: { icon: CheckCircle, color: "status-hired", label: "Hired" },
  rejected: { icon: XCircle, color: "status-rejected", label: "Rejected" },
};

const ApplicationsPage = () => {
  const { user } = useAuth();
  const [applications, setApplications] = useState<Application[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("all");

  useEffect(() => {
    if (user) {
      fetchApplications();
    }
  }, [user]);

  const fetchApplications = async () => {
    try {
      const { data, error } = await supabase
        .from("applications")
        .select(`
          *,
          job:jobs(
            id,
            title,
            company:companies(id, name, logo_url)
          )
        `)
        .eq("user_id", user!.id)
        .order("created_at", { ascending: false });

      if (error) throw error;
      
      const formattedApplications = (data || []).map(app => ({
        ...app,
        job: Array.isArray(app.job) ? app.job[0] : app.job,
      })).map(app => ({
        ...app,
        job: app.job ? {
          ...app.job,
          company: Array.isArray(app.job.company) ? app.job.company[0] : app.job.company
        } : null
      }));
      
      setApplications(formattedApplications);
    } catch (err) {
      console.error("Error fetching applications:", err);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString("en-IN", {
      month: "short",
      day: "numeric",
      year: "numeric",
    });
  };

  const filteredApplications = applications.filter((app) => {
    if (activeTab === "all") return true;
    if (activeTab === "active") {
      return !["hired", "rejected"].includes(app.status);
    }
    if (activeTab === "completed") {
      return ["hired", "rejected"].includes(app.status);
    }
    return app.status === activeTab;
  });

  const stats = {
    total: applications.length,
    active: applications.filter((a) => !["hired", "rejected"].includes(a.status)).length,
    interviews: applications.filter((a) => a.status === "interview").length,
    offers: applications.filter((a) => ["offer", "hired"].includes(a.status)).length,
  };

  const ApplicationSkeleton = () => (
    <Card>
      <CardContent className="p-4">
        <div className="flex items-center gap-4">
          <Skeleton className="h-12 w-12 rounded-lg" />
          <div className="flex-1 space-y-2">
            <Skeleton className="h-5 w-3/4" />
            <Skeleton className="h-4 w-1/2" />
          </div>
          <Skeleton className="h-6 w-20" />
        </div>
      </CardContent>
    </Card>
  );

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <div className="container mx-auto px-4 py-6">
        <h1 className="text-2xl font-bold font-display mb-6">My Applications</h1>

        {/* Stats Cards */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-primary">{stats.total}</div>
              <div className="text-sm text-muted-foreground">Total Applied</div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-info">{stats.active}</div>
              <div className="text-sm text-muted-foreground">Active</div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-warning">{stats.interviews}</div>
              <div className="text-sm text-muted-foreground">Interviews</div>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-4">
              <div className="text-2xl font-bold text-success">{stats.offers}</div>
              <div className="text-sm text-muted-foreground">Offers</div>
            </CardContent>
          </Card>
        </div>

        {/* Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="mb-6">
          <TabsList>
            <TabsTrigger value="all">All</TabsTrigger>
            <TabsTrigger value="active">Active</TabsTrigger>
            <TabsTrigger value="interview">Interviews</TabsTrigger>
            <TabsTrigger value="completed">Completed</TabsTrigger>
          </TabsList>
        </Tabs>

        {/* Applications List */}
        <div className="space-y-4">
          {loading ? (
            Array.from({ length: 5 }).map((_, i) => <ApplicationSkeleton key={i} />)
          ) : filteredApplications.length === 0 ? (
            <Card>
              <CardContent className="py-12 text-center">
                <Briefcase className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                <h3 className="font-semibold mb-2">No applications found</h3>
                <p className="text-muted-foreground text-sm mb-4">
                  {activeTab === "all"
                    ? "Start applying to jobs to see them here"
                    : "No applications match this filter"}
                </p>
                <Button asChild>
                  <Link to="/jobs">Browse Jobs</Link>
                </Button>
              </CardContent>
            </Card>
          ) : (
            filteredApplications.map((app) => {
              const config = statusConfig[app.status] || statusConfig.applied;
              const StatusIcon = config.icon;

              return (
                <Card key={app.id} className="card-hover">
                  <CardContent className="p-4">
                    <div className="flex items-center gap-4">
                      {/* Company Logo */}
                      <div className="h-12 w-12 rounded-lg bg-muted flex items-center justify-center shrink-0">
                        {app.job?.company?.logo_url ? (
                          <img
                            src={app.job.company.logo_url}
                            alt={app.job.company.name}
                            className="h-10 w-10 rounded object-contain"
                          />
                        ) : (
                          <Briefcase className="h-5 w-5 text-muted-foreground" />
                        )}
                      </div>

                      {/* Job Info */}
                      <div className="flex-1 min-w-0">
                        <Link
                          to={`/jobs/${app.job?.id}`}
                          className="font-semibold hover:text-primary transition-colors line-clamp-1"
                        >
                          {app.job?.title || "Job"}
                        </Link>
                        <p className="text-sm text-muted-foreground">
                          {app.job?.company?.name || "Company"} • Applied{" "}
                          {formatDate(app.created_at)}
                        </p>
                      </div>

                      {/* Status Badge */}
                      <Badge
                        variant="outline"
                        className={cn("gap-1 shrink-0", config.color)}
                      >
                        <StatusIcon className="h-3 w-3" />
                        {config.label}
                      </Badge>

                      <ChevronRight className="h-5 w-5 text-muted-foreground hidden sm:block" />
                    </div>

                    {/* Additional Info */}
                    {(app.interview_date || app.company_feedback) && (
                      <div className="mt-4 pt-4 border-t space-y-2">
                        {app.interview_date && (
                          <div className="flex items-center gap-2 text-sm">
                            <Calendar className="h-4 w-4 text-warning" />
                            <span>
                              Interview scheduled:{" "}
                              {new Date(app.interview_date).toLocaleString("en-IN", {
                                dateStyle: "medium",
                                timeStyle: "short",
                              })}
                            </span>
                          </div>
                        )}
                        {app.company_feedback && (
                          <div className="flex items-start gap-2 text-sm">
                            <MessageSquare className="h-4 w-4 text-muted-foreground mt-0.5" />
                            <span className="text-muted-foreground">
                              {app.company_feedback}
                            </span>
                          </div>
                        )}
                      </div>
                    )}
                  </CardContent>
                </Card>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
};

export default ApplicationsPage;
