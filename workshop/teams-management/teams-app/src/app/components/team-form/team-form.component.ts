// src/app/components/team-form/team-form.component.ts
import { Component, Output, EventEmitter } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { TeamsService } from '../../services/teams.service';
import { TeamCreate } from '../../models/team.model';

@Component({
  selector: 'app-team-form',
  templateUrl: './team-form.component.html',
  styleUrls: ['./team-form.component.css']
})
export class TeamFormComponent {
  @Output() teamCreated = new EventEmitter<void>();
  
  teamForm: FormGroup;
  isSubmitting = false;
  errorMessage = '';

  constructor(
    private fb: FormBuilder,
    private teamsService: TeamsService
  ) {
    this.teamForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(2)]]
    });
  }

  onSubmit() {
    if (this.teamForm.valid) {
      this.isSubmitting = true;
      this.errorMessage = '';
      
      const teamData: TeamCreate = {
        name: this.teamForm.value.name.trim()
      };

      this.teamsService.createTeam(teamData).subscribe({
        next: () => {
          this.teamForm.reset();
          this.teamCreated.emit();
          this.isSubmitting = false;
        },
        error: (error) => {
          this.errorMessage = error;
          this.isSubmitting = false;
        }
      });
    }
  }

  get name() {
    return this.teamForm.get('name');
  }
}
