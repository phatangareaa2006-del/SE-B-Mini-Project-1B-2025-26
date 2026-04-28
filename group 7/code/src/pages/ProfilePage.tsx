import { useAuth } from "@/contexts/AuthContext";
import { useProfile } from "@/hooks/useProfile";
import Navbar from "@/components/layout/Navbar";
import { ProfileHeader } from "@/components/profile/ProfileHeader";
import { AboutSection } from "@/components/profile/AboutSection";
import { EducationSection } from "@/components/profile/EducationSection";
import { ExperienceSection } from "@/components/profile/ExperienceSection";
import { SkillsSection } from "@/components/profile/SkillsSection";
import { ProjectsSection } from "@/components/profile/ProjectsSection";
import { CertificationsSection } from "@/components/profile/CertificationsSection";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Skeleton } from "@/components/ui/skeleton";
import { Card, CardContent } from "@/components/ui/card";
import { Navigate } from "react-router-dom";

const ProfilePage = () => {
  const { user, loading: authLoading } = useAuth();

  const {
    profile,
    education,
    experience,
    skills,
    certifications,
    projects,
    loading,
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
  } = useProfile(user?.id);

  // Redirect if not logged in
  if (!authLoading && !user) {
    return <Navigate to="/auth" replace />;
  }

  if (loading || authLoading) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mx-auto px-4 py-6 max-w-4xl">
          <Card className="mb-6">
            <CardContent className="p-6">
              <div className="flex items-center gap-4">
                <Skeleton className="h-28 w-28 rounded-full" />
                <div className="space-y-2 flex-1">
                  <Skeleton className="h-6 w-48" />
                  <Skeleton className="h-4 w-32" />
                  <Skeleton className="h-4 w-64" />
                </div>
              </div>
            </CardContent>
          </Card>
          <div className="space-y-4">
            <Skeleton className="h-10 w-full" />
            <Skeleton className="h-48 w-full" />
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <div className="container mx-auto px-4 py-6 max-w-4xl">
        {/* Profile Header with Image Upload */}
        <div className="mb-6">
          <ProfileHeader
            profile={profile}
            onUpdate={updateProfile}
            userId={user!.id}
          />
        </div>

        {/* Main Content Tabs */}
        <Tabs defaultValue="about" className="space-y-6">
          <TabsList className="grid w-full grid-cols-3 sm:grid-cols-5 h-auto">
            <TabsTrigger value="about" className="text-xs sm:text-sm">About</TabsTrigger>
            <TabsTrigger value="experience" className="text-xs sm:text-sm">Experience</TabsTrigger>
            <TabsTrigger value="education" className="text-xs sm:text-sm">Education</TabsTrigger>
            <TabsTrigger value="skills" className="text-xs sm:text-sm hidden sm:flex">Skills</TabsTrigger>
            <TabsTrigger value="projects" className="text-xs sm:text-sm hidden sm:flex">Projects</TabsTrigger>
          </TabsList>

          {/* Mobile: Additional tabs */}
          <div className="flex sm:hidden gap-2">
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="skills" className="text-xs">Skills</TabsTrigger>
              <TabsTrigger value="projects" className="text-xs">Projects</TabsTrigger>
            </TabsList>
          </div>

          {/* About Tab */}
          <TabsContent value="about" className="space-y-6">
            <AboutSection
              bio={profile?.bio || null}
              onUpdate={async (bio) => updateProfile({ bio })}
            />
          </TabsContent>

          {/* Experience Tab */}
          <TabsContent value="experience">
            <ExperienceSection
              experience={experience}
              onAdd={addExperience}
              onUpdate={updateExperience}
              onDelete={deleteExperience}
            />
          </TabsContent>

          {/* Education Tab */}
          <TabsContent value="education">
            <EducationSection
              education={education}
              onAdd={addEducation}
              onUpdate={updateEducation}
              onDelete={deleteEducation}
            />
          </TabsContent>

          {/* Skills Tab */}
          <TabsContent value="skills">
            <SkillsSection
              skills={skills}
              onAdd={addSkill}
              onUpdate={updateSkillProficiency}
              onDelete={deleteSkill}
            />
          </TabsContent>

          {/* Projects Tab */}
          <TabsContent value="projects">
            <ProjectsSection
              projects={projects}
              onAdd={addProject}
              onUpdate={updateProject}
              onDelete={deleteProject}
            />
          </TabsContent>
        </Tabs>

        {/* Certifications - Always visible below tabs */}
        <div className="mt-6">
          <CertificationsSection
            certifications={certifications}
            userId={user!.id}
            onAdd={addCertification}
            onUpdate={updateCertification}
            onDelete={deleteCertification}
          />
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;
