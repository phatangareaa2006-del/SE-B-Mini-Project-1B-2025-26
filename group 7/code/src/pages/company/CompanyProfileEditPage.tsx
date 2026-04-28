import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Building2, Loader2, Globe, Linkedin } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Form, FormControl, FormField, FormItem, FormLabel, FormMessage,
} from "@/components/ui/form";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import Navbar from "@/components/layout/Navbar";
import { useAuth } from "@/contexts/AuthContext";
import { apiClient } from "@/api/client";
import { toast } from "sonner";

const companySchema = z.object({
  name: z.string().min(2, "Company name required"),
  description: z.string().optional(),
  industry: z.string().optional(),
  company_size: z.string().optional(),
  headquarters: z.string().optional(),
  website: z.string().url("Enter a valid URL").optional().or(z.literal("")),
  linkedin_url: z.string().url("Enter a valid URL").optional().or(z.literal("")),
  founded_year: z.coerce.number().min(1800).max(2030).optional(),
  culture: z.string().optional(),
});

type CompanyFormData = z.infer<typeof companySchema>;

const CompanyProfileEditPage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [existingId, setExistingId] = useState<string | null>(null);

  const form = useForm<CompanyFormData>({
    resolver: zodResolver(companySchema),
    defaultValues: {
      name: "", description: "", industry: "", company_size: "",
      headquarters: "", website: "", linkedin_url: "", culture: "",
    },
  });

  useEffect(() => {
    const fetch = async () => {
      if (!user) return;
      try {
        const data = await apiClient.getMyCompany();
        if (data) {
          setExistingId(data.id);
          form.reset({
            name: data.name || "",
            description: data.description || "",
            industry: data.industry || "",
            company_size: data.company_size || "",
            headquarters: data.headquarters || "",
            website: data.website || "",
            linkedin_url: data.linkedin_url || "",
            founded_year: data.founded_year || undefined,
            culture: data.culture || "",
          });
        }
      } catch (error) {
        console.error("Error loading company:", error);
      } finally {
        setLoading(false);
      }
    };
    fetch();
  }, [user]);

  const onSubmit = async (data: CompanyFormData) => {
    if (!user) return;
    setSaving(true);
    try {
      await apiClient.updateCompany(data);
      toast.success(existingId ? "Company profile updated!" : "Company profile created!");
      navigate("/company/dashboard");
    } catch (err: any) {
      toast.error(err.message || "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="flex items-center justify-center py-20">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <div className="container mx-auto px-4 py-6 max-w-3xl">
        <h1 className="text-2xl font-bold mb-6">{existingId ? "Edit" : "Create"} Company Profile</h1>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <Card>
              <CardHeader><CardTitle>Basic Information</CardTitle></CardHeader>
              <CardContent className="space-y-4">
                <FormField control={form.control} name="name" render={({ field }) => (
                  <FormItem>
                    <FormLabel>Company Name *</FormLabel>
                    <FormControl><Input placeholder="e.g. Acme Corp" {...field} /></FormControl>
                    <FormMessage />
                  </FormItem>
                )} />
                <FormField control={form.control} name="description" render={({ field }) => (
                  <FormItem>
                    <FormLabel>About</FormLabel>
                    <FormControl><Textarea placeholder="Tell candidates about your company..." className="min-h-[100px]" {...field} /></FormControl>
                    <FormMessage />
                  </FormItem>
                )} />
                <div className="grid sm:grid-cols-2 gap-4">
                  <FormField control={form.control} name="industry" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Industry</FormLabel>
                      <FormControl><Input placeholder="e.g. Technology" {...field} /></FormControl>
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="company_size" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Company Size</FormLabel>
                      <Select onValueChange={field.onChange} value={field.value}>
                        <FormControl><SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger></FormControl>
                        <SelectContent>
                          <SelectItem value="1-10">1-10</SelectItem>
                          <SelectItem value="11-50">11-50</SelectItem>
                          <SelectItem value="51-200">51-200</SelectItem>
                          <SelectItem value="201-500">201-500</SelectItem>
                          <SelectItem value="501-1000">501-1000</SelectItem>
                          <SelectItem value="1000+">1000+</SelectItem>
                          <SelectItem value="10000+">10,000+</SelectItem>
                        </SelectContent>
                      </Select>
                    </FormItem>
                  )} />
                </div>
                <div className="grid sm:grid-cols-2 gap-4">
                  <FormField control={form.control} name="headquarters" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Headquarters</FormLabel>
                      <FormControl><Input placeholder="e.g. Mumbai, India" {...field} /></FormControl>
                    </FormItem>
                  )} />
                  <FormField control={form.control} name="founded_year" render={({ field }) => (
                    <FormItem>
                      <FormLabel>Founded Year</FormLabel>
                      <FormControl><Input type="number" placeholder="e.g. 2015" {...field} /></FormControl>
                    </FormItem>
                  )} />
                </div>
                <FormField control={form.control} name="website" render={({ field }) => (
                  <FormItem>
                    <FormLabel>Website</FormLabel>
                    <FormControl><Input placeholder="https://example.com" {...field} /></FormControl>
                    <FormMessage />
                  </FormItem>
                )} />
                <FormField control={form.control} name="linkedin_url" render={({ field }) => (
                  <FormItem>
                    <FormLabel>LinkedIn</FormLabel>
                    <FormControl><Input placeholder="https://linkedin.com/company/..." {...field} /></FormControl>
                    <FormMessage />
                  </FormItem>
                )} />
                <FormField control={form.control} name="culture" render={({ field }) => (
                  <FormItem>
                    <FormLabel>Company Culture</FormLabel>
                    <FormControl><Textarea placeholder="Describe your work culture, values..." {...field} /></FormControl>
                  </FormItem>
                )} />
              </CardContent>
            </Card>

            <div className="flex justify-end gap-4">
              <Button type="button" variant="outline" onClick={() => navigate("/company/dashboard")}>Cancel</Button>
              <Button type="submit" disabled={saving}>
                {saving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {existingId ? "Save Changes" : "Create Profile"}
              </Button>
            </div>
          </form>
        </Form>
      </div>
    </div>
  );
};

export default CompanyProfileEditPage;
