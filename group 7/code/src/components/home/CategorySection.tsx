import {
  Briefcase,
  GraduationCap,
  Trophy,
  FileText,
  Users,
  BookOpen,
  Code,
} from "lucide-react";
import CategoryCard from "./CategoryCard";

const categories = [
  {
    title: "Internships",
    icon: <Briefcase className="h-8 w-8 text-orange-600" />,
    href: "/internships",
    gradient: "from-orange-100 to-orange-200 dark:from-orange-900/30 dark:to-orange-800/30",
  },
  {
    title: "Jobs",
    icon: <Briefcase className="h-8 w-8 text-blue-600" />,
    href: "/jobs",
    gradient: "from-blue-100 to-blue-200 dark:from-blue-900/30 dark:to-blue-800/30",
  },
  {
    title: "Competitions",
    icon: <Trophy className="h-8 w-8 text-yellow-600" />,
    href: "/competitions",
    gradient: "from-yellow-100 to-yellow-200 dark:from-yellow-900/30 dark:to-yellow-800/30",
  },
  {
    title: "Mock Tests",
    icon: <FileText className="h-8 w-8 text-red-600" />,
    href: "/mock-tests",
    gradient: "from-red-100 to-red-200 dark:from-red-900/30 dark:to-red-800/30",
  },
  {
    title: "Mentorships",
    icon: <Users className="h-8 w-8 text-purple-600" />,
    href: "/mentorships",
    gradient: "from-purple-100 to-purple-200 dark:from-purple-900/30 dark:to-purple-800/30",
  },
  {
    title: "Courses",
    icon: <BookOpen className="h-8 w-8 text-green-600" />,
    href: "/courses",
    gradient: "from-green-100 to-green-200 dark:from-green-900/30 dark:to-green-800/30",
  },
];

const CategorySection = () => {
  return (
    <div className="flex gap-4 overflow-x-auto pb-4 scrollbar-hide -mx-2 px-2">
      {categories.map((category) => (
        <CategoryCard
          key={category.title}
          title={category.title}
          icon={category.icon}
          href={category.href}
          gradient={category.gradient}
        />
      ))}
    </div>
  );
};

export default CategorySection;
