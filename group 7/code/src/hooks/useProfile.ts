import { useState, useEffect, useCallback } from "react";
import { apiClient } from "@/api/client";
import { toast } from "sonner";

interface Profile {
  id: string;
  user_id: string;
  email: string;
  full_name?: string;
  avatar_url?: string;
  headline?: string;
  bio?: string;
  location?: string;
  linkedin_url?: string;
  github_url?: string;
  portfolio_url?: string;
  resume_url?: string;
  phone?: string;
  website?: string;
  created_at: string;
  updated_at: string;
}

interface Education {
  id: string;
  user_id: string;
  institution: string;
  degree: string;
  field_of_study?: string;
  start_date?: string;
  end_date?: string;
  is_current: boolean;
  grade?: string;
  cgpa?: number;
  description?: string;
  created_at: string;
  updated_at: string;
}

interface Experience {
  id: string;
  user_id: string;
  company_name: string;
  title: string;
  employment_type?: string;
  location?: string;
  start_date: string;
  end_date?: string;
  is_current: boolean;
  description?: string;
  created_at: string;
  updated_at: string;
}

interface Certification {
  id: string;
  user_id: string;
  name: string;
  issuing_organization: string;
  issue_date?: string;
  expiry_date?: string;
  credential_id?: string;
  credential_url?: string;
  certificate_url?: string;
  created_at: string;
  updated_at: string;
}

interface Project {
  id: string;
  user_id: string;
  title: string;
  description?: string;
  project_url?: string;
  github_url?: string;
  image_url?: string;
  technologies?: string[];
  start_date?: string;
  end_date?: string;
  is_featured: boolean;
  created_at: string;
  updated_at: string;
}

interface Achievement {
  id: string;
  user_id: string;
  title: string;
  description?: string;
  date_achieved?: string;
  issuer?: string;
  url?: string;
  created_at: string;
}

interface UserSkill {
  id: string;
  skill_id: string;
  proficiency_level: number | null;
  skill: {
    id: string;
    name: string;
    category: string | null;
  };
}

export interface ProfileData {
  profile: Profile | null;
  education: Education[];
  experience: Experience[];
  skills: UserSkill[];
  certifications: Certification[];
  projects: Project[];
  achievements: Achievement[];
}

export const useProfile = (userId: string | undefined) => {
  const [data, setData] = useState<ProfileData>({
    profile: null,
    education: [],
    experience: [],
    skills: [],
    certifications: [],
    projects: [],
    achievements: [],
  });
  const [loading, setLoading] = useState(true);

  const fetchAll = useCallback(async () => {
    if (!userId) return;

    try {
      const [profile, education, experience] = await Promise.all([
        apiClient.getProfile().catch(() => null),
        apiClient.getEducation().catch(() => []),
        apiClient.getExperience().catch(() => []),
      ]);

      setData({
        profile: profile || null,
        education: education || [],
        experience: experience || [],
        skills: [],
        certifications: [],
        projects: [],
        achievements: [],
      });
    } catch (err) {
      console.error("Error fetching profile:", err);
      toast.error("Failed to load profile");
    } finally {
      setLoading(false);
    }
  }, [userId]);

  useEffect(() => {
    fetchAll();
  }, [fetchAll]);

  // Profile Updates
  const updateProfile = async (updates: Partial<Profile>) => {
    if (!userId) return false;
    try {
      const updated = await apiClient.updateProfile(updates);
      setData((prev) => ({
        ...prev,
        profile: updated || prev.profile,
      }));
      toast.success("Profile updated!");
      return true;
    } catch (err: any) {
      toast.error(err.message || "Failed to update profile");
      return false;
    }
  };

  // Education CRUD
  const addEducation = async (edu: Omit<Education, "id" | "created_at" | "updated_at" | "user_id">) => {
    if (!userId) return null;
    try {
      const newEdu = await apiClient.addEducation(edu);
      setData((prev) => ({ ...prev, education: [newEdu, ...prev.education] }));
      toast.success("Education added!");
      return newEdu;
    } catch (err: any) {
      toast.error(err.message || "Failed to add education");
      return null;
    }
  };

  const updateEducation = async (id: string, updates: Partial<Education>) => {
    try {
      const updated = await apiClient.updateEducation(id, updates);
      setData((prev) => ({
        ...prev,
        education: prev.education.map((e) => (e.id === id ? { ...e, ...updated } : e)),
      }));
      toast.success("Education updated!");
      return true;
    } catch (err: any) {
      toast.error(err.message || "Failed to update education");
      return false;
    }
  };

  const deleteEducation = async (id: string) => {
    try {
      await apiClient.deleteEducation(id);
      setData((prev) => ({
        ...prev,
        education: prev.education.filter((e) => e.id !== id),
      }));
      toast.success("Education deleted!");
      return true;
    } catch (err: any) {
      toast.error(err.message || "Failed to delete education");
      return false;
    }
  };

  // Experience CRUD
  const addExperience = async (exp: Omit<Experience, "id" | "created_at" | "updated_at" | "user_id">) => {
    if (!userId) return null;
    try {
      const newExp = await apiClient.addExperience(exp);
      setData((prev) => ({ ...prev, experience: [newExp, ...prev.experience] }));
      toast.success("Experience added!");
      return newExp;
    } catch (err: any) {
      toast.error(err.message || "Failed to add experience");
      return null;
    }
  };

  const updateExperience = async (id: string, updates: Partial<Experience>) => {
    try {
      const updated = await apiClient.updateExperience(id, updates);
      setData((prev) => ({
        ...prev,
        experience: prev.experience.map((e) => (e.id === id ? { ...e, ...updated } : e)),
      }));
      toast.success("Experience updated!");
      return true;
    } catch (err: any) {
      toast.error(err.message || "Failed to update experience");
      return false;
    }
  };

  const deleteExperience = async (id: string) => {
    try {
      await apiClient.deleteExperience(id);
      setData((prev) => ({
        ...prev,
        experience: prev.experience.filter((e) => e.id !== id),
      }));
      toast.success("Experience deleted!");
      return true;
    } catch (err: any) {
      toast.error(err.message || "Failed to delete experience");
      return false;
    }
  };

  // Certification CRUD
  const addCertification = async (cert: Omit<Certification, "id" | "created_at" | "updated_at" | "user_id">) => {
    if (!userId) return null;
    try {
      // API endpoint for certifications would be needed
      // For now, returning null
      toast.info("Certification management coming soon");
      return null;
    } catch (err: any) {
      toast.error(err.message || "Failed to add certification");
      return null;
    }
  };

  const updateCertification = async (id: string, updates: Partial<Certification>) => {
    try {
      toast.info("Certification management coming soon");
      return false;
    } catch (err: any) {
      toast.error(err.message || "Failed to update certification");
      return false;
    }
  };

  const deleteCertification = async (id: string) => {
    try {
      toast.info("Certification management coming soon");
      return false;
    } catch (err: any) {
      toast.error(err.message || "Failed to delete certification");
      return false;
    }
  };

  // Skills CRUD
  const addSkill = async (skillName: string, proficiencyLevel: number = 3) => {
    if (!userId) return null;
    try {
      toast.info("Skill management coming soon");
      return null;
    } catch (err: any) {
      toast.error(err.message || "Failed to add skill");
      return null;
    }
  };

  const updateSkillProficiency = async (userSkillId: string, proficiencyLevel: number) => {
    try {
      toast.info("Skill management coming soon");
      return false;
    } catch (err: any) {
      toast.error(err.message || "Failed to update skill");
      return false;
    }
  };

  const deleteSkill = async (userSkillId: string) => {
    try {
      toast.info("Skill management coming soon");
      return false;
    } catch (err: any) {
      toast.error(err.message || "Failed to remove skill");
      return false;
    }
  };

  // Projects CRUD
  const addProject = async (project: Omit<Project, "id" | "created_at" | "updated_at" | "user_id">) => {
    if (!userId) return null;
    try {
      toast.info("Project management coming soon");
      return null;
    } catch (err: any) {
      toast.error(err.message || "Failed to add project");
      return null;
    }
  };

  const updateProject = async (id: string, updates: Partial<Project>) => {
    try {
      toast.info("Project management coming soon");
      return false;
    } catch (err: any) {
      toast.error(err.message || "Failed to update project");
      return false;
    }
  };

  const deleteProject = async (id: string) => {
    try {
      toast.info("Project management coming soon");
      return false;
    } catch (err: any) {
      toast.error(err.message || "Failed to delete project");
      return false;
    }
  };

  return {
    ...data,
    loading,
    refetch: fetchAll,
    updateProfile,
    addEducation,
    updateEducation,
    deleteEducation,
    addExperience,
    updateExperience,
    deleteExperience,
    addCertification,
    updateCertification,
    deleteCertification,
    addSkill,
    updateSkillProficiency,
    deleteSkill,
    addProject,
    updateProject,
    deleteProject,
  };
};
