{{/*
Expand the name of the chart.
*/}}
{{- define "car-rental.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "car-rental.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "car-rental.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "car-rental.labels" -}}
helm.sh/chart: {{ include "car-rental.chart" . }}
{{ include "car-rental.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "car-rental.selectorLabels" -}}
app.kubernetes.io/name: {{ include "car-rental.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account for auth-api
*/}}
{{- define "car-rental.authServiceAccountName" -}}
{{- if .Values.auth.serviceAccount.create }}
{{- default (include "car-rental.fullname" .) .Values.auth.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.auth.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account for cars-api
*/}}
{{- define "car-rental.carsServiceAccountName" -}}
{{- if .Values.cars.serviceAccount.create }}
{{- default (include "car-rental.fullname" .) .Values.cars.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.cars.serviceAccount.name }}
{{- end }}
{{- end }}

