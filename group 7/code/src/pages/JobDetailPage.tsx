import { useState, useMemo } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import {
  ChevronLeft, MapPin, Building2, IndianRupee, Clock, Briefcase,
  Bookmark, BookmarkCheck, ExternalLink, CheckCircle, XCircle, Users, Globe
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Separator } from "@/components/ui/separator";
import { Skeleton } from "@/components/ui/skeleton";
import Navbar from "@/components/layout/Navbar";
import { useAuth } from "@/contexts/AuthContext";
import { apiClient } from "@/api/client";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

const JobDetailPage = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [applying, setApplying] = useState(false);

  // Check if this is a jobs table or opportunities table ID
  const { data: job, isLoading } = useQuery({
    queryKey: ["job-detail", id],
    queryFn: async () => {
      // Try jobs table first
      const { data: jobData, error: jobError } = await supabase
        .from("jobs")
        .select(`*, company:companies(id, name, logo_url, industry, description, headquarters, company_size, website, founded_year), job_skills(is_required, skill:skills(id, name))`)
        .eq("id", id!)
        .single();

      if (!jobError && jobData) {
        return {
          ...jobData,
          company: Array.isArray(jobData.company) ? jobData.company[0] : jobData.company,
          job_skills: (jobData.job_skills || []).map((js: any) => ({
            ...js,
            skill: Array.isArray(js.skill) ? js.skill[0] : js.skill,
          })),
          source: "jobs" as const,
        };
      }

      // Try opportunities table
      const { data: oppData, error: oppError } = await supabase
        .from("opportunities")
        .select("*")
        .eq("id", id!)
        .single();

      if (oppError) throw oppError;
      return { ...oppData, source: "opportunities" as const };
    },
    enabled: !!id,
  });

  // User skills
  const { data: userSkills } = useQuery({
    queryKey: ["user-skills-for-match", user?.id],
    queryFn: async () => {
      if (!user) return [];
      const { data, error } = await supabase
        .from("user_skills")
        .select("skill:skills(name)")
        .eq("user_id", user.id);
      if (error) throw error;
      return data?.map((s: any) => (Array.isArray(s.skill) ? s.skill[0]?.name : s.skill?.name)?.toLowerCase()).filter(Boolean) || [];
    },
    enabled: !!user,
  });

  // Skill match calculation
  const skillMatch = useMemo(() => {
    if (!job || !userSkills) return null;

    let requiredSkills: string[] = [];
    if (job.source === "jobs" && (job as any).job_skills) {
      requiredSkills = (job as any).job_skills.map((js: any) => js.skill?.name?.toLowerCase()).filter(Boolean);
    } else if ((job as any).required_skills) {
      requiredSkills = (job as any).required_skills.map((s: string) => s.toLowerCase());
    }

    if (requiredSkills.length === 0) return { percent: 100, matched: [], missing: [] };

    const matched = requiredSkills.filter((s) => userSkills.includes(s));
    const missing = requiredSkills.filter((s) => !userSkills.includes(s));
    const percent = Math.round((matched.length / requiredSkills.length) * 100);

    return { percent, matched, missing };
  }, [job, userSkills]);

  const canApply = !skillMatch || skillMatch.percent >= 40;

  // Check existing application
  const { data: existingApp } = useQuery({
    queryKey: ["existing-application", id, user?.id],
    queryFn: async () => {
      if (!user || !id) return null;
      if (job?.source === "jobs") {
        const { data } = await supabase
          .from("applications")
          .select("id, status")
          .eq("job_id", id)
          .eq("user_id", user.id)
          .single();
        return data;
      }
      const { data } = await supabase
        .from("opportunity_registrations")
        .select("id, status")
        .eq("opportunity_id", id)
        .eq("user_id", user.id)
        .single();
      return data;
    },
    enabled: !!user && !!id && !!job,
  });

  const handleApply = async () => {
    if (!user) {
      toast.error("Please sign in to apply");
      navigate("/auth");
      return;
    }
    if (!canApply) {
      toast.error("You need at least 40% skill match to apply");
      return;
    }
    setApplying(true);
    try {
      if (job?.source === "jobs") {
        await apiClient.applyJob(id!, {
          skillMatch: skillMatch?.percent || 0,
        });
      } else {
        await apiClient.registerForOpportunity(id!);
      }
      toast.success("Application submitted successfully!");
    } catch (err: any) {
      toast.error(err.message || "Failed to apply");
    } finally {
      setApplying(false);
    }
  };

  const formatSalary = (min: number | null, max: number | null) => {
    if (!min && !max) return "Not disclosed";
    const fmt = (v: number) => `₹${(v / 100000).toFixed(1)} LPA`;
    if (min && max) return `${fmt(min)} - ${fmt(max)}`;
    if (min) return `${fmt(min)}+`;
    return `Up to ${fmt(max!)}`;
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mx-auto px-4 py-6 max-w-4xl">
          <Skeleton className="h-8 w-32 mb-4" />
          <Skeleton className="h-48 w-full rounded-xl mb-6" />
          <Skeleton className="h-96 w-full rounded-xl" />
        </div>
      </div>
    );
  }

  if (!job) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mx-auto px-4 py-20 text-center">
          <h2 className="text-2xl font-bold mb-4">Job not found</h2>
          <Button asChild><Link to="/jobs">Browse Jobs</Link></Button>
        </div>
      </div>
    );
  }

  const isOpp = job.source === "opportunities";
  const title = job.title;
  const companyName = isOpp ? job.organizer_name : job.company?.name;
  const companyLogo = isOpp ? job.organizer_logo : job.company?.logo_url;
  const description = job.description;
  const locations = isOpp ? job.locations : job.locations;

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <div className="container mx-auto px-4 py-6 max-w-4xl">
        <Link to="/jobs" className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-6">
          <ChevronLeft className="h-4 w-4" /> Back to Jobs
        </Link>

        {/* Header */}
        <Card className="mb-6">
          <CardContent className="p-6">
            <div className="flex gap-4">
              <div className="h-16 w-16 rounded-xl bg-muted flex items-center justify-center shrink-0">
                {companyLogo ? (
                  <img src={companyLogo} alt={companyName || ""} className="h-12 w-12 rounded-lg object-contain" />
                ) : (
                  <Building2 className="h-8 w-8 text-muted-foreground" />
                )}
              </div>
              <div className="flex-1">
                <h1 className="text-2xl font-bold mb-1">{title}</h1>
                <p className="text-muted-foreground">{companyName}</p>
                <div className="flex flex-wrap gap-2 mt-3">
                  {locations?.map((loc: string) => (
                    <Badge key={loc} variant="secondary" className="gap-1">
                      <MapPin className="h-3 w-3" /> {loc}
                    </Badge>
                  ))}
                  {!isOpp && job.min_salary && (
                    <Badge variant="secondary" className="gap-1">
                      <IndianRupee className="h-3 w-3" /> {formatSalary(job.min_salary, job.max_salary)}
                    </Badge>
                  )}
                  {isOpp && job.stipend_min && (
                    <Badge variant="secondary" className="gap-1">
                      <IndianRupee className="h-3 w-3" /> ₹{(job.stipend_min / 1000).toFixed(0)}K - ₹{((job.stipend_max || job.stipend_min) / 1000).toFixed(0)}K/mo
                    </Badge>
                  )}
                  {!isOpp && (
                    <Badge variant="secondary" className="gap-1 capitalize">
                      <Briefcase className="h-3 w-3" /> {job.job_type?.replace("_", " ")}
                    </Badge>
                  )}
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <div className="grid lg:grid-cols-3 gap-6">
          {/* Main content */}
          <div className="lg:col-span-2 space-y-6">
            <Card>
              <CardHeader><CardTitle>Description</CardTitle></CardHeader>
              <CardContent>
                <div className="prose prose-sm dark:prose-invert max-w-none whitespace-pre-wrap">
                  {description}
                </div>
              </CardContent>
            </Card>

            {!isOpp && job.requirements && (
              <Card>
                <CardHeader><CardTitle>Requirements</CardTitle></CardHeader>
                <CardContent>
                  <div className="prose prose-sm dark:prose-invert max-w-none whitespace-pre-wrap">
                    {job.requirements}
                  </div>
                </CardContent>
              </Card>
            )}

            {!isOpp && job.responsibilities && (
              <Card>
                <CardHeader><CardTitle>Responsibilities</CardTitle></CardHeader>
                <CardContent>
                  <div className="prose prose-sm dark:prose-invert max-w-none whitespace-pre-wrap">
                    {job.responsibilities}
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Company Info */}
            {!isOpp && job.company && (
              <Card>
                <CardHeader><CardTitle>About {job.company.name}</CardTitle></CardHeader>
                <CardContent className="space-y-3">
                  {job.company.description && <p className="text-sm text-muted-foreground">{job.company.description}</p>}
                  <div className="flex flex-wrap gap-4 text-sm">
                    {job.company.industry && <span className="flex items-center gap-1"><Building2 className="h-4 w-4" /> {job.company.industry}</span>}
                    {job.company.company_size && <span className="flex items-center gap-1"><Users className="h-4 w-4" /> {job.company.company_size}</span>}
                    {job.company.headquarters && <span className="flex items-center gap-1"><MapPin className="h-4 w-4" /> {job.company.headquarters}</span>}
                    {job.company.website && (
                      <a href={job.company.website} target="_blank" rel="noopener" className="flex items-center gap-1 text-primary hover:underline">
                        <Globe className="h-4 w-4" /> Website
                      </a>
                    )}
                  </div>
                </CardContent>
              </Card>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Apply Card */}
            <Card>
              <CardContent className="p-6">
                {existingApp ? (
                  <div className="text-center">
                    <CheckCircle className="h-10 w-10 text-green-500 mx-auto mb-2" />
                    <p className="font-semibold">Already Applied</p>
                    <Badge className="mt-2 capitalize">{existingApp.status?.replace("_", " ")}</Badge>
                  </div>
                ) : (
                  <>
                    <Button onClick={handleApply} disabled={applying || !canApply} className="w-full mb-3" size="lg">
                      {applying ? "Submitting..." : canApply ? "Apply Now" : "Skill Match Too Low"}
                    </Button>
                    {!canApply && (
                      <p className="text-xs text-destructive text-center">
                        You need at least 40% skill match to apply. Add more skills to your profile.
                      </p>
                    )}
                  </>
                )}
              </CardContent>
            </Card>

            {/* Skill Match */}
            {user && skillMatch && (
              <Card>
                <CardHeader><CardTitle className="text-sm">Skill Match</CardTitle></CardHeader>
                <CardContent>
                  <div className="text-center mb-4">
                    <div className={cn("text-3xl font-bold", skillMatch.percent >= 70 ? "text-green-500" : skillMatch.percent >= 40 ? "text-primary" : "text-destructive")}>
                      {skillMatch.percent}%
                    </div>
                    <Progress value={skillMatch.percent} className="h-2 mt-2" />
                  </div>
                  {skillMatch.matched.length > 0 && (
                    <div className="mb-3">
                      <p className="text-xs font-medium text-green-600 mb-1">✓ Matched Skills</p>
                      <div className="flex flex-wrap gap-1">
                        {skillMatch.matched.map((s) => (
                          <Badge key={s} variant="outline" className="text-xs border-green-300 text-green-600 capitalize">{s}</Badge>
                        ))}
                      </div>
                    </div>
                  )}
                  {skillMatch.missing.length > 0 && (
                    <div>
                      <p className="text-xs font-medium text-destructive mb-1">✗ Missing Skills</p>
                      <div className="flex flex-wrap gap-1">
                        {skillMatch.missing.map((s) => (
                          <Badge key={s} variant="outline" className="text-xs border-destructive/30 text-destructive capitalize">{s}</Badge>
                        ))}
                      </div>
                    </div>
                  )}
                  <Separator className="my-3" />
                  <Link to="/profile" className="text-xs text-primary hover:underline">Add more skills →</Link>
                </CardContent>
              </Card>
            )}

            {/* Quick Info */}
            <Card>
              <CardContent className="p-4 space-y-3 text-sm">
                {!isOpp && job.openings && (
                  <div className="flex justify-between"><span className="text-muted-foreground">Openings</span><span className="font-medium">{job.openings}</span></div>
                )}
                {!isOpp && job.application_deadline && (
                  <div className="flex justify-between"><span className="text-muted-foreground">Deadline</span><span className="font-medium">{new Date(job.application_deadline).toLocaleDateString()}</span></div>
                )}
                {isOpp && job.registration_deadline && (
                  <div className="flex justify-between"><span className="text-muted-foreground">Deadline</span><span className="font-medium">{new Date(job.registration_deadline).toLocaleDateString()}</span></div>
                )}
                {isOpp && job.duration && (
                  <div className="flex justify-between"><span className="text-muted-foreground">Duration</span><span className="font-medium">{job.duration}</span></div>
                )}
                {!isOpp && job.min_experience !== null && (
                  <div className="flex justify-between"><span className="text-muted-foreground">Experience</span><span className="font-medium">{job.min_experience}+ years</span></div>
                )}
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
};

export default JobDetailPage;
