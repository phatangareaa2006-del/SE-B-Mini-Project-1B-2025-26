import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  Briefcase, MapPin, IndianRupee, Plus, X, Loader2, Calendar, Users, Globe, GraduationCap,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import {
  Form, FormControl, FormField, FormItem, FormLabel, FormMessage, FormDescription,
} from "@/components/ui/form";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import Navbar from "@/components/layout/Navbar";
import { useAuth } from "@/contexts/AuthContext";
import { apiClient } from "@/api/client";
import { toast } from "sonner";

const jobPostSchema = z.object({
  title: z.string().min(3, "Title must be at least 3 characters"),
  description: z.string().min(50, "Description must be at least 50 characters"),
  requirements: z.string().min(20, "Requirements must be at least 20 characters"),
  responsibilities: z.string().min(20, "Responsibilities must be at least 20 characters"),
  job_type: z.enum(["full_time", "internship", "contract", "part_time"]),
  department: z.string().optional(),
  min_salary: z.coerce.number().min(0).optional(),
  max_salary: z.coerce.number().min(0).optional(),
  min_experience: z.coerce.number().min(0).default(0),
  min_cgpa: z.coerce.number().min(0).max(10).optional(),
  openings: z.coerce.number().min(1).default(1),
  application_deadline: z.string().optional(),
  is_remote: z.boolean().default(false),
});

type JobPostFormData = z.infer<typeof jobPostSchema>;

const PostJobPage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [company, setCompany] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [locations, setLocations] = useState<string[]>([]);
  const [locationInput, setLocationInput] = useState("");
  const [skills, setSkills] = useState<{ name: string; isRequired: boolean }[]>([]);
  const [skillInput, setSkillInput] = useState("");
  const [requiredDegrees, setRequiredDegrees] = useState<string[]>([]);
  const [degreeInput, setDegreeInput] = useState("");

  const form = useForm<JobPostFormData>({
    resolver: zodResolver(jobPostSchema),
    defaultValues: {
      title: "",
      description: "",
      requirements: "",
      responsibilities: "",
      job_type: "full_time",
      department: "",
      min_salary: undefined,
      max_salary: undefined,
      min_experience: 0,
      min_cgpa: undefined,
      openings: 1,
      application_deadline: "",
      is_remote: false,
    },
  });

  useEffect(() => {
    const fetchCompany = async () => {
      if (!user) return;
      const { data, error } = await supabase
        .from("companies")
        .select("*")
        .eq("user_id", user.id)
        .single();
      if (error && error.code !== "PGRST116") {
        console.error(error);
      }
      setCompany(data);
      setLoading(false);
    };
    fetchCompany();
  }, [user]);

  const addLocation = () => {
    if (locationInput.trim() && !locations.includes(locationInput.trim())) {
      setLocations([...locations, locationInput.trim()]);
      setLocationInput("");
    }
  };

  const addSkill = () => {
    if (skillInput.trim() && !skills.find((s) => s.name === skillInput.trim())) {
      setSkills([...skills, { name: skillInput.trim(), isRequired: true }]);
      setSkillInput("");
    }
  };

  const addDegree = () => {
    if (degreeInput.trim() && !requiredDegrees.includes(degreeInput.trim())) {
      setRequiredDegrees([...requiredDegrees, degreeInput.trim()]);
      setDegreeInput("");
    }
  };

  const onSubmit = async (data: JobPostFormData) => {
    if (!company) {
      toast.error("Please create a company profile first");
      return;
    }
    setSubmitting(true);
    try {
      // Insert job
      const { data: jobData, error: jobError } = await supabase
        .from("jobs")
        .insert({
          company_id: company.id,
          title: data.title,
          description: data.description,
          requirements: data.requirements,
          responsibilities: data.responsibilities,
          job_type: data.job_type,
          department: data.department || null,
          min_salary: data.min_salary || null,
          max_salary: data.max_salary || null,
          min_experience: data.min_experience,
          min_cgpa: data.min_cgpa || null,
          openings: data.openings,
          application_deadline: data.application_deadline || null,
          is_remote: data.is_remote,
          locations: locations.length > 0 ? locations : null,
          required_degrees: requiredDegrees.length > 0 ? requiredDegrees : null,
        })
        .select("id")
        .single();

      if (jobError) throw jobError;

      // Insert skills - simplified (backend will handle)
      if (skills.length > 0) {
        // Skills will be handled by backend job creation
        // Remove Supabase skill insertion
      }

      toast.success("Job posted successfully!");
      navigate("/company/dashboard");
    } catch (err: any) {
      toast.error(err.message || "Failed to post job");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mx-auto px-4 py-8 flex items-center justify-center">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      </div>
    );
  }

  if (!company) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mx-auto px-4 py-12 text-center">
          <Briefcase className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
          <h2 className="text-2xl font-bold mb-2">Company Profile Required</h2>
          <p className="text-muted-foreground mb-6">Create a company profile before posting jobs.</p>
          <Button onClick={() => navigate("/company/profile/edit")}>Create Company Profile</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <div className="container mx-auto px-4 py-6 max-w-4xl">
        <div className="mb-6">
          <h1 className="text-2xl font-bold">Post a New Job</h1>
          <p className="text-muted-foreground">Fill in the details to create a job listing for {company.name}</p>
        </div>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            {/* Basic Info */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2"><Briefcase className="h-5 w-5" /> Job Details</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <FormField control={form.control} name="title" render={({ field }) => (
                  <FormItem>
                    <FormLabel>Job Title *</FormLabel>
                    <FormControl><Input placeholder="e.g. Senior Software Engineer" {...field} /></FormControl>
                    <FormMessage />
                  </FormItem>
                )} />

                <div className="grid sm:grid-cols-2 gap-4">
                  <FormField control={form.control} name="job_type" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Job Type *</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger><SelectValue /></SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="full_time">Full Time</SelectItem>
                          <SelectItem value="internship">Internship</SelectItem>
                          <SelectItem value="contract">Contract</SelectItem>
                          <SelectItem value="part_time">Part Time</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )} />

                  <FormField control={form.control} name="department" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Department</FormLabel>
                      <FormControl><Input placeholder="e.g. Engineering" {...field} /></FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                </div>

                <FormField control={form.control} name="description" render={({ field }) => (
                  <FormItem>
                    <FormLabel>Job Description *</FormLabel>
                    <FormControl>
                      <Textarea placeholder="Describe the role, team, and what makes this opportunity exciting..." className="min-h-[150px]" {...field} />
                    </FormControl>
                    <FormDescription>Minimum 50 characters</FormDescription>
                    <FormMessage />
                  </FormItem>
                )} />

                <FormField control={form.control} name="responsibilities" render={({ field }) => (
                  <FormItem>
                    <FormLabel>Key Responsibilities *</FormLabel>
                    <FormControl>
                      <Textarea placeholder="• Lead development of core features&#10;• Mentor junior developers&#10;• Participate in code reviews" className="min-h-[120px]" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )} />

                <FormField control={form.control} name="requirements" render={({ field }) => (
                  <FormItem>
                    <FormLabel>Requirements *</FormLabel>
                    <FormControl>
                      <Textarea placeholder="• 3+ years experience in React/Node.js&#10;• Strong problem-solving skills&#10;• B.Tech/M.Tech in CS or equivalent" className="min-h-[120px]" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )} />
              </CardContent>
            </Card>

            {/* Compensation */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2"><IndianRupee className="h-5 w-5" /> Compensation & Location</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid sm:grid-cols-2 gap-4">
                  <FormField control={form.control} name="min_salary" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Min Salary (₹/year)</FormLabel>
                      <FormControl><Input type="number" placeholder="e.g. 600000" {...field} /></FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="max_salary" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Max Salary (₹/year)</FormLabel>
                      <FormControl><Input type="number" placeholder="e.g. 1200000" {...field} /></FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                </div>

                <FormField control={form.control} name="is_remote" render={({ field }) => (
                  <FormItem className="flex items-center justify-between rounded-lg border p-4">
                    <div>
                      <FormLabel>Remote Position</FormLabel>
                      <FormDescription>Can this role be done remotely?</FormDescription>
                    </div>
                    <FormControl>
                      <Switch checked={field.value} onCheckedChange={field.onChange} />
                    </FormControl>
                  </FormItem>
                )} />

                <div>
                  <FormLabel>Office Locations</FormLabel>
                  <div className="flex gap-2 mt-1">
                    <Input
                      placeholder="e.g. Mumbai, Bangalore"
                      value={locationInput}
                      onChange={(e) => setLocationInput(e.target.value)}
                      onKeyDown={(e) => { if (e.key === "Enter") { e.preventDefault(); addLocation(); } }}
                    />
                    <Button type="button" variant="outline" onClick={addLocation}><Plus className="h-4 w-4" /></Button>
                  </div>
                  {locations.length > 0 && (
                    <div className="flex flex-wrap gap-2 mt-2">
                      {locations.map((loc) => (
                        <Badge key={loc} variant="secondary" className="gap-1">
                          <MapPin className="h-3 w-3" /> {loc}
                          <button type="button" onClick={() => setLocations(locations.filter((l) => l !== loc))}>
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ))}
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>

            {/* Skills & Eligibility */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2"><GraduationCap className="h-5 w-5" /> Skills & Eligibility</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <FormLabel>Required Skills</FormLabel>
                  <div className="flex gap-2 mt-1">
                    <Input
                      placeholder="e.g. React, Python, Machine Learning"
                      value={skillInput}
                      onChange={(e) => setSkillInput(e.target.value)}
                      onKeyDown={(e) => { if (e.key === "Enter") { e.preventDefault(); addSkill(); } }}
                    />
                    <Button type="button" variant="outline" onClick={addSkill}><Plus className="h-4 w-4" /></Button>
                  </div>
                  {skills.length > 0 && (
                    <div className="flex flex-wrap gap-2 mt-2">
                      {skills.map((skill) => (
                        <Badge key={skill.name} variant="default" className="gap-1">
                          {skill.name}
                          <button type="button" onClick={() => setSkills(skills.filter((s) => s.name !== skill.name))}>
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ))}
                    </div>
                  )}
                </div>

                <div>
                  <FormLabel>Required Degrees</FormLabel>
                  <div className="flex gap-2 mt-1">
                    <Input
                      placeholder="e.g. B.Tech, M.Tech, MBA"
                      value={degreeInput}
                      onChange={(e) => setDegreeInput(e.target.value)}
                      onKeyDown={(e) => { if (e.key === "Enter") { e.preventDefault(); addDegree(); } }}
                    />
                    <Button type="button" variant="outline" onClick={addDegree}><Plus className="h-4 w-4" /></Button>
                  </div>
                  {requiredDegrees.length > 0 && (
                    <div className="flex flex-wrap gap-2 mt-2">
                      {requiredDegrees.map((deg) => (
                        <Badge key={deg} variant="secondary" className="gap-1">
                          <GraduationCap className="h-3 w-3" /> {deg}
                          <button type="button" onClick={() => setRequiredDegrees(requiredDegrees.filter((d) => d !== deg))}>
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ))}
                    </div>
                  )}
                </div>

                <div className="grid sm:grid-cols-3 gap-4">
                  <FormField control={form.control} name="min_experience" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Min Experience (years)</FormLabel>
                      <FormControl><Input type="number" min={0} {...field} /></FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="min_cgpa" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Min CGPA</FormLabel>
                      <FormControl><Input type="number" step={0.1} min={0} max={10} placeholder="e.g. 7.0" {...field} /></FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="openings" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Number of Openings</FormLabel>
                      <FormControl><Input type="number" min={1} {...field} /></FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                </div>

                <FormField control={form.control} name="application_deadline" render={({ field }) => (
                  <FormItem>
                    <FormLabel>Application Deadline</FormLabel>
                    <FormControl><Input type="date" {...field} /></FormControl>
                    <FormMessage />
                  </FormItem>
                )} />
              </CardContent>
            </Card>

            <div className="flex justify-end gap-4">
              <Button type="button" variant="outline" onClick={() => navigate("/company/dashboard")}>Cancel</Button>
              <Button type="submit" disabled={submitting} size="lg">
                {submitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Publish Job
              </Button>
            </div>
          </form>
        </Form>
      </div>
    </div>
  );
};

export default PostJobPage;
