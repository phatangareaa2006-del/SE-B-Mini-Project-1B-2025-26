import { cn } from "@/lib/utils";
import { Check, X } from "lucide-react";

interface PasswordStrengthIndicatorProps {
  password: string;
}

const PasswordStrengthIndicator = ({
  password,
}: PasswordStrengthIndicatorProps) => {
  const requirements = [
    {
      label: "At least 8 characters",
      met: password.length >= 8,
    },
    {
      label: "One uppercase letter",
      met: /[A-Z]/.test(password),
    },
    {
      label: "One lowercase letter",
      met: /[a-z]/.test(password),
    },
    {
      label: "One number",
      met: /\d/.test(password),
    },
    {
      label: "One special character (@$!%*?&)",
      met: /[@$!%*?&]/.test(password),
    },
  ];

  const metCount = requirements.filter((r) => r.met).length;
  const strength =
    metCount === 0
      ? 0
      : metCount <= 2
      ? 1
      : metCount <= 4
      ? 2
      : 3;

  const strengthLabels = ["Weak", "Fair", "Good", "Strong"];
  const strengthColors = [
    "bg-destructive",
    "bg-warning",
    "bg-info",
    "bg-success",
  ];

  if (!password) return null;

  return (
    <div className="space-y-3 animate-fade-in">
      {/* Strength Bar */}
      <div className="space-y-1.5">
        <div className="flex gap-1">
          {[0, 1, 2, 3].map((index) => (
            <div
              key={index}
              className={cn(
                "h-1 flex-1 rounded-full transition-colors duration-300",
                index <= strength - 1 ? strengthColors[strength - 1] : "bg-muted"
              )}
            />
          ))}
        </div>
        {strength > 0 && (
          <p
            className={cn(
              "text-xs font-medium",
              strength === 1
                ? "text-destructive"
                : strength === 2
                ? "text-warning"
                : strength === 3
                ? "text-info"
                : "text-success"
            )}
          >
            {strengthLabels[strength - 1]}
          </p>
        )}
      </div>

      {/* Requirements List */}
      <ul className="space-y-1">
        {requirements.map((req, index) => (
          <li
            key={index}
            className={cn(
              "flex items-center gap-2 text-xs transition-colors",
              req.met ? "text-success" : "text-muted-foreground"
            )}
          >
            {req.met ? (
              <Check className="h-3.5 w-3.5" />
            ) : (
              <X className="h-3.5 w-3.5" />
            )}
            {req.label}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default PasswordStrengthIndicator;
